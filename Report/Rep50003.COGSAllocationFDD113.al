report 50003 "COGS Allocation FDD113"
{
    ApplicationArea = All;
    Caption = 'COGS Allocation';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            // DataItemTableView =;
            DataItemTableView = sorting(Number) where(Number = const(1));

            trigger OnPostDataItem()
            var
                NewEntryType: Option Sales,Scrap,Adjustment,Revalue;
            begin
                Process(NewEntryType::Sales);
                Process(NewEntryType::Scrap);
                Process(NewEntryType::Revalue);
                Process(NewEntryType::Adjustment);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Options';
                    field(FromDate; FromDate)
                    {
                        Caption = 'From Date:';
                        ApplicationArea = Basic, Suite;
                        trigger OnValidate()
                        begin
                        end;
                    }
                    field(ToDate; ToDate)
                    {
                        Caption = 'To Date:';
                        ApplicationArea = Basic, Suite;
                        trigger OnValidate()
                        begin
                        end;
                    }
                    /* field("Journal Template"; JournalTemplate)
                    {
                        TableRelation = "Gen. Journal Template".Name;

                        trigger OnValidate()
                        begin
                            GenBatch.Reset();
                            GenBatch.SetRange("Journal Template Name", JournalTemplate);
                            Clear(JournalBatchName);
                        end;
                    } */
                    field("Journal Batch Name"; JournalBatchName)
                    {
                        ApplicationArea = Basic, Suite;
                        //TableRelation = GenBatch;//"Gen. Journal Batch".Name where("Journal Template Name" = const(JournalTemplate.Name));
                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if PAGE.RunModal(0, GenBatch) = ACTION::LookupOK then begin
                                JournalBatchName := GenBatch.Name;
                            end;
                        end;

                    }

                    field(PostingDate; PostingDate)
                    {
                        Caption = 'Posting Date:';
                        ApplicationArea = Basic, Suite;
                    }
                    field(Department; Department)
                    {
                        TableRelation = "Dimension Value".Code where("Dimension Code" = const('DEPARTMENT'), Code = filter('100|200|300|400|800'));
                        Caption = 'Department:';
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }

        trigger OnInit()
        begin
            GenBatch.Reset();
            GenBatch.SetRange("Journal Template Name", JournalTemplate);
            JournalBatchName := 'DEFAULT';
        end;
    }

    var
        FromDate: Date;
        ToDate: Date;
        JournalTemplate: Label 'GENERAL';// Code[10];
        JournalBatchName: Code[10];//Label 'DEFAULT';
        PostingDate: Date;
        Department: Code[20];
        GenBatch: Record "Gen. Journal Batch";

    //GenJnlLine: Record "Gen. Journal Line";
    //GenPstGrp: Record "Gen. Product Posting Group";
    //MCenter: Record "Machine Center";
    //ValueEntry: Record "Value Entry";

    trigger OnPreReport()
    begin
        if FromDate > ToDate then
            Error('From Date muse less than To Date.');

        if Department = '' then
            Error('Department can not be empty.');

        if PostingDate = 0D then
            Error('Posting date can not be empty.');
    end;


    procedure Process(EntryType: Option Sales,Scrap,Adjustment,Revalue)
    var
        TotalQuery: Query "COGS Allocation VE Query";
        DepartTotal_F: Decimal;
        ItmTotalCst_B: Decimal;
        ItmTotalCst_C: Decimal;
        CurAllocCst_E: Decimal;
        AllAllocCst: Decimal;
        DepartAjdAmt: Decimal;
        OffsetAmt: Decimal;
        OffsetAmt_Credit: Decimal;
        OffsetAmt_Debit: Decimal;
        MCenter: Record "Machine Center";
        GenPrdPstGrp: Record "Gen. Product Posting Group";
        PstGrop: Code[20];
        GenJnlLine: Record "Gen. Journal Line";
        GLLineNo: Integer;
        GLSetup: Record "General Ledger Setup";
        GLDocNo: Code[20];
        GLActNo: Code[20];
        NoSeries: Codeunit "No. Series";
        ConstantNoS: Label 'GJNL-GEN';

        CalcBOMTree: Codeunit "Calculate BOM Tree";
        HasBOM: Boolean;
        ShowByOption: Option;
        ItemFilter: Code[250];
        ShowBy: Enum "BOM Structure Show By";
        ConstantTxt: Label '''%1''', Locked = true;
        BOMBuff: Record "BOM Buffer" temporary;
        ItemCal: Record Item;
        AsmHeader: Record "Assembly Header";
        ProdOrderLine: Record "Prod. Order Line";
        BOMCostSharesCal: Record "BOM Cost shares Calculated";
        EntryNo: Integer;
        CurParentNo: Code[20];
    begin
        DepartTotal_F := 0;
        AllAllocCst := 0;
        OffsetAmt_Debit := 0;
        OffsetAmt_Credit := 0;

        TotalQuery.SetQueryFilter(FromDate, ToDate, Department, EntryType);
        if TotalQuery.Open() then begin
            BOMCostSharesCal.Reset();//FDD113

            if EntryType = EntryType::Sales then//version 5.01
                BOMCostSharesCal.DeleteAll();//FDD113

            GLLineNo := 0;
            GenJnlLine.Reset();
            GenJnlLine.SetRange("Journal Template Name", JournalTemplate);//'GENERAL');
            GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);// 'DEFAULT');
            if GenJnlLine.FindSet() then
                if EntryType = EntryType::Sales then//version 5.01                        
                    GenJnlLine.DeleteAll()
                else begin//version 5.01
                    GenJnlLine.FindLast();
                    GLLineNo := GenJnlLine."Line No.";
                end;//version 5.01

            GLDocNo := NoSeries.PeekNextNo(ConstantNoS, PostingDate);//GetNextNo(ConstantNoS, PostingDate);

            GLSetup.Reset();
            GLSetup.Get();

            EntryNo := 0;

            if BOMCostSharesCal.FindLast() then//version 5.01
                EntryNo := BOMCostSharesCal."Entry No.";

            while TotalQuery.Read() do begin
                if TotalQuery.Item_No_ <> '' then begin
                    DepartTotal_F := DepartTotal_F + TotalQuery.CostAmountActual_A;

                    BOMBuff.Reset();
                    BOMBuff.DeleteAll();
                    ItemCal.Get(TotalQuery.Item_No_);
                    ItemFilter := '';
                    if ItemCal."No." <> '' then
                        ItemFilter := StrSubstNo(ConstantTxt, ItemCal."No.");
                    ShowBy := ShowBy::Item;

                    ShowByOption := ShowBy.AsInteger();
                    ShowBy := Enum::"BOM Structure Show By".FromInteger(ShowByOption);

                    ItemCal.SetFilter("No.", ItemFilter);
                    ItemCal.SetRange("Date Filter", 0D, WorkDate());
                    CalcBOMTree.SetItemFilter(ItemCal);

                    case ShowBy of
                        ShowBy::Item:
                            begin
                                ItemCal.FindSet();
                                repeat
                                    HasBOM := ItemCal.HasBOM() or (ItemCal."Routing No." <> '')
                                until HasBOM or (ItemCal.Next() = 0);

                                //if not HasBOM then
                                //    Error(Text000);
                                if HasBOM then
                                    CalcBOMTree.GenerateTreeForItems(ItemCal, BOMBuff, 2);
                            end;
                        ShowBy::Production:
                            CalcBOMTree.GenerateTreeForProdLine(ProdOrderLine, BOMBuff, 2);
                        ShowBy::Assembly:
                            CalcBOMTree.GenerateTreeForAsm(AsmHeader, BOMBuff, 2);
                    end;



                    BOMBuff.Reset();
                    if BOMBuff.FindFirst() then
                        repeat
                            EntryNo := EntryNo + 1;
                            BOMCostSharesCal.Init();
                            BOMCostSharesCal.TransferFields(BOMBuff);
                            BOMCostSharesCal."Entry No." := EntryNo;

                            BOMCostSharesCal.Department := Department;
                            if (BOMBuff.Indentation > 0) then begin
                                BOMCostSharesCal."Parent Item No." := TotalQuery.Item_No_;//                                        
                            end;
                            //BOMCostSharesCal.Insert();

                            if BOMBuff."Is Leaf" then
                                ItmTotalCst_C := BOMBuff."Total Cost"
                            else if BOMBuff.Indentation = 0 then begin
                                ItmTotalCst_B := BOMBuff."Total Cost";
                                CurParentNo := BOMBuff."No.";
                            end;

                            if (BOMBuff."Is Leaf") then begin // and (ItmTotalCst_B <> 0)
                                if ItmTotalCst_B = 0 then Error(StrSubstNo('The Total Cost of the parent Item %1 is Zero.', CurParentNo));

                                CurAllocCst_E := Round(TotalQuery.CostAmountActual_A * ItmTotalCst_C / ItmTotalCst_B, 0.01) * -1;//Abs
                                AllAllocCst := AllAllocCst + CurAllocCst_E;

                                if CurAllocCst_E > 0 then
                                    OffsetAmt_Debit := OffsetAmt_Debit + Abs(CurAllocCst_E)
                                else
                                    OffsetAmt_Credit := OffsetAmt_Credit + Abs(CurAllocCst_E);

                                Clear(PstGrop);
                                case BOMBuff.Type of
                                    BOMBuff.Type::Item:
                                        begin
                                            ItemCal.Reset();
                                            ItemCal.Get(BOMBuff."No.");
                                            PstGrop := ItemCal."Gen. Prod. Posting Group";
                                        end;

                                    BOMBuff.Type::"Machine Center":
                                        begin
                                            MCenter.Reset();
                                            MCenter.Get(BOMBuff."No.");
                                            PstGrop := MCenter."Gen. Prod. Posting Group";
                                            //GLActNo := MCenter."COGS Allocation Account";
                                        end;
                                end;
                                GenPrdPstGrp.Reset();
                                GenPrdPstGrp.Get(PstGrop);

                                case EntryType of//version 5.01
                                    EntryType::Sales:
                                        GLActNo := GenPrdPstGrp."COGS Allocation Account";
                                    EntryType::Scrap:
                                        GLActNo := GenPrdPstGrp."SCRAP Allocation Account";//version 5.01
                                    EntryType::Adjustment:
                                        GLActNo := GenPrdPstGrp."ADJUSTMENT Allocation Account";//version 5.01
                                    EntryType::Revalue:
                                        GLActNo := GenPrdPstGrp."REVALUE Allocation Account";//version 6.0
                                end;//version 5.01


                                BOMCostSharesCal."ValueEntry Total Cost" := TotalQuery.CostAmountActual_A;
                                BOMCostSharesCal.Rate := BOMBuff."Total Cost" / ItmTotalCst_B;
                                BOMCostSharesCal."Line Allocate Cost" := CurAllocCst_E;//Abs
                                BOMCostSharesCal."GL Acct." := GLActNo;//GenPrdPstGrp."COGS Allocation Account";

                                GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::"G/L Account");
                                GenJnlLine.SetRange("Account No.", GLActNo);//GenPrdPstGrp."COGS Allocation Account");
                                GenJnlLine.SetRange("Shortcut Dimension 1 Code", Department);
                                GenJnlLine.SetRange(Comment, Format(EntryType)); //COGS,SCRAP,ADJUSTMENT should be different Gen Lines.
                                                                                 /* Comment out for merge - and + amount with same GL Account # into 1 general journal line.
                                                                                 if CurAllocCst_E < 0 then
                                                                                     GenJnlLine.SetFilter(Amount, '<0')
                                                                                 else
                                                                                     GenJnlLine.SetFilter(Amount, '>0'); */
                                if not GenJnlLine.FindFirst() then begin
                                    GLLineNo := GLLineNo + 10000;

                                    GenJnlLine.Init();
                                    GenJnlLine.Validate("Journal Template Name", JournalTemplate);//'GENERAL');
                                    GenJnlLine.Validate("Journal Batch Name", JournalBatchName);// 'DEFAULT');
                                    GenJnlLine.Validate("Line No.", GLLineNo);
                                    GenJnlLine.Validate("Posting Date", PostingDate);
                                    GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::" ");
                                    GenJnlLine.Validate("Document No.", GLDocNo);
                                    GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                                    GenJnlLine.Validate("Account No.", GLActNo);//GenPrdPstGrp."COGS Allocation Account");
                                    GenJnlLine.Validate("Shortcut Dimension 1 Code", Department);
                                    GenJnlLine.Validate("Amount", CurAllocCst_E);
                                    /* if CurAllocCst_E < 0 then
                                        GenJnlLine.Validate("Debit Amount", Abs(CurAllocCst_E))
                                    else if CurAllocCst_E > 0 then
                                        GenJnlLine.Validate("Credit Amount", Abs(CurAllocCst_E) * -1); */
                                    //GenJnlLine.Description := TotalQuery.Item_No_ + ': ' + BOMBuff."No.";
                                    GenJnlLine.Comment := Format(EntryType); //COGS,SCRAP,ADJUSTMENT should be different Gen Lines.
                                    GenJnlLine.Insert(true);
                                end
                                else begin
                                    /* if CurAllocCst_E < 0 then
                                        GenJnlLine.Validate("Debit Amount", GenJnlLine."Debit Amount" + Abs(CurAllocCst_E))
                                    else if CurAllocCst_E > 0 then
                                        GenJnlLine.Validate("Credit Amount", GenJnlLine."Credit Amount" + Abs(CurAllocCst_E) * -1); */
                                    //GenJnlLine.Description := GenJnlLine.Description + '; ' + BOMBuff."No.";
                                    GenJnlLine.Validate("Amount", GenJnlLine."Amount" + CurAllocCst_E);
                                    GenJnlLine.Modify();
                                end;
                            end;
                            BOMCostSharesCal."Entry Type" := EntryType;//version 5.01
                            BOMCostSharesCal.Insert();
                        until BOMBuff.Next() = 0;
                end;

            end;


            DepartTotal_F := Round(DepartTotal_F, 0.01);

            //if (DepartTotal_F <> 0) then begin //version 5.01//(AllAllocCst <> 0) and
            GenJnlLine.Reset();
            GenJnlLine.SetRange("Journal Template Name", JournalTemplate);//'GENERAL');
            GenJnlLine.SetRange("Journal Batch Name", JournalBatchName);// 'DEFAULT');
            if GenJnlLine.FindFirst() then begin
                repeat
                    BOMCostSharesCal.Reset();
                    BOMCostSharesCal.SetRange("GL Acct.", GenJnlLine."Account No.");
                    if BOMCostSharesCal.FindSet() then
                        BOMCostSharesCal.ModifyAll("G/L Account Cost", GenJnlLine."Amount");//"Amount (LCY)"
                until GenJnlLine.Next() = 0;
            end;


            if DepartTotal_F <> 0 then begin
                GLLineNo := GLLineNo + 10000;
                GenJnlLine.Init();
                GenJnlLine.Validate("Journal Template Name", JournalTemplate);//'GENERAL');
                GenJnlLine.Validate("Journal Batch Name", JournalBatchName);// 'DEFAULT');
                GenJnlLine.Validate("Line No.", GLLineNo);
                GenJnlLine.Validate("Posting Date", PostingDate);
                GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::" ");
                GenJnlLine.Validate("Document No.", GLDocNo);
                GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");

                //GenJnlLine.Validate("Account No.", GLSetup."COGS Alloc. Offset Account");
                case EntryType of
                    EntryType::Sales:
                        GenJnlLine.Validate("Account No.", GLSetup."COGS Alloc. Offset Account");
                    EntryType::Adjustment:
                        GenJnlLine.Validate("Account No.", GLSetup."Adjust Alloc. Offset Account");
                    EntryType::Scrap:
                        GenJnlLine.Validate("Account No.", GLSetup."Scrap Alloc. Offset Account");
                    EntryType::Revalue:
                        GenJnlLine.Validate("Account No.", GLSetup."Revalue Alloc. Offset Account");
                end;
                GenJnlLine.Validate("Shortcut Dimension 1 Code", Department);
                GenJnlLine.Validate("Amount", DepartTotal_F);//"Amount (LCY)"
                OffsetAmt_Credit := OffsetAmt_Credit + Abs(GenJnlLine."Credit Amount");
                OffsetAmt_Debit := OffsetAmt_Debit + Abs(GenJnlLine."Debit Amount");
                GenJnlLine.Comment := 'Offset';
                //GenJnlLine.Description := 'Offset : ' + TotalQuery.Item_No_;
                GenJnlLine.Insert(true);
            end;

            DepartAjdAmt := Abs(OffsetAmt_Debit) - Abs(OffsetAmt_Credit);//Abs(DepartTotal_F) - Abs(AllAllocCst);
            if DepartAjdAmt <> 0 then begin
                GLLineNo := GLLineNo + 10000;

                GenJnlLine.Init();
                GenJnlLine.Validate("Journal Template Name", JournalTemplate);//'GENERAL');
                GenJnlLine.Validate("Journal Batch Name", JournalBatchName);// 'DEFAULT');
                GenJnlLine.Validate("Line No.", GLLineNo);
                GenJnlLine.Validate("Posting Date", PostingDate);
                GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::" ");
                GenJnlLine.Validate("Document No.", GLDocNo);
                GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                GenJnlLine.Validate("Account No.", GLSetup."COGS Alloc. Rounding Account");
                GenJnlLine.Validate("Shortcut Dimension 1 Code", Department);
                //GenJnlLine.Validate("Amount", DepartAjdAmt);
                if DepartAjdAmt < 0 then
                    GenJnlLine.Validate("Debit Amount", Abs(DepartAjdAmt))
                else
                    GenJnlLine.Validate("Credit Amount", Abs(DepartAjdAmt));
                //GenJnlLine.Description := 'Rounding : ' + TotalQuery.Item_No_;
                GenJnlLine.Comment := 'Adj Balance';
                GenJnlLine.Insert(true);
            end;
            TotalQuery.Close();
        end;

        if EntryType = EntryType::Adjustment then//version 5.01
            Page.Run(Page::"BOM Cost shares Calculated");
    end;
}

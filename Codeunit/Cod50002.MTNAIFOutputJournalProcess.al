codeunit 50002 MTNAIFOutputJournalProcess
{
    //CS 2024/8/13 Channing.Zhou FDD301 CodeUnit for MTNA IF Output Journal Process
    //CS 2025/10/21 Channing.Zhou FDD300 V7 Change the notification email contents, add error information page url.

    trigger OnRun()
    var
        ErrorRecCount: Integer;
    begin
        if ProcessAllData(ErrorRecCount) then begin
        end;
    end;

    [TryFunction]
    procedure ProcessAllData(var ErrorRecCount: Integer)
    var
        RecMTNA_IF_OutputJournal: Record "MTNA_IF_OutputJournal";
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        MaxProcCount: Integer;
    begin
        RecMTNA_IF_OutputJournal.Reset();
        RecMTNA_IF_OutputJournal.SetRange(Status, RecMTNA_IF_OutputJournal.Status::Ready);
        if RecMTNA_IF_OutputJournal.FindFirst() then begin
            MaxProcCount := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Output journal");
            if RecMTNAIFConfiguration.FindFirst() then begin
                MaxProcCount := RecMTNAIFConfiguration."Max. records to process";
            end;
            RecMTNAIFConfiguration.Reset();
            ProcessOutputJournalData(RecMTNA_IF_OutputJournal, MaxProcCount, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcessOutputJournalData(var RecMTNA_IF_OutputJournal: Record "MTNA_IF_OutputJournal"; MaxProcCount: Integer; var ErrorRecCount: Integer)
    var
        RecOutputJournalLine: Record "Item Journal Line";
        ErrorMessageText: Text;
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
        pagMTNA_IF_OutputJournalErr: Page "MTNA_IF_OutputJournalErr";
        proccessedCount: Integer;
    begin
        ErrorRecCount := 0;
        proccessedCount := 0;
        if RecMTNA_IF_OutputJournal.FindFirst() then begin
            repeat
                proccessedCount += 1;
                if RecMTNA_IF_OutputJournal.Status = RecMTNA_IF_OutputJournal.Status::Ready then begin
                    RecMTNA_IF_OutputJournal."Process start datetime" := CurrentDateTime;
                    RecOutputJournalLine.Reset();
                    RecOutputJournalLine.SetRange("Journal Batch Name", RecMTNA_IF_OutputJournal."Journal Batch Name");
                    if RecOutputJournalLine.FindFirst() then begin
                        RecOutputJournalLine.DeleteAll();
                    end;
                    RecOutputJournalLine.Reset();
                    Clear(RecOutputJournalLine);
                    if InsertItemJournalLine(RecMTNA_IF_OutputJournal, RecOutputJournalLine) then begin
                        Commit();
                        if CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", RecOutputJournalLine) then begin
                            RecMTNA_IF_OutputJournal.Status := RecMTNA_IF_OutputJournal.Status::Completed;
                            RecMTNA_IF_OutputJournal.Modify();
                        end
                        else begin
                            ErrorMessageText := GetLastErrorText();
                            RecMTNA_IF_OutputJournal.Status := RecMTNA_IF_OutputJournal.Status::Error;
                            RecMTNA_IF_OutputJournal.SetErrormessage('Error occurred when posting Item Journal Line, the detailed error message is: ' + ErrorMessageText);
                            RecMTNA_IF_OutputJournal.Modify();
                            RecOutputJournalLine.Delete();
                            if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Output Journal Process Post', RecMTNA_IF_OutputJournal.Plant, Format(RecMTNA_IF_OutputJournal."Entry No."),
                                RecMTNA_IF_OutputJournal."Process start datetime", ErrorMessageText, pagMTNA_IF_OutputJournalErr.Caption, pagMTNA_IF_OutputJournalErr.ObjectId(false)) then begin
                            end;
                            ErrorRecCount += 1;
                        end;
                    end
                    else begin
                        ErrorMessageText := GetLastErrorText();
                        RecMTNA_IF_OutputJournal.Status := RecMTNA_IF_OutputJournal.Status::Error;
                        RecMTNA_IF_OutputJournal.SetErrormessage('Error occurred when inserting Item Journal Line. The detailed error message is: ' + ErrorMessageText);
                        RecMTNA_IF_OutputJournal.Modify();
                        if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Output Journal Process Insert', RecMTNA_IF_OutputJournal.Plant, Format(RecMTNA_IF_OutputJournal."Entry No."),
                            RecMTNA_IF_OutputJournal."Process start datetime", ErrorMessageText, pagMTNA_IF_OutputJournalErr.Caption, pagMTNA_IF_OutputJournalErr.ObjectId(false)) then begin
                        end;
                        ErrorRecCount += 1;
                        RecOutputJournalLine.Reset();
                        RecOutputJournalLine.SetRange("Journal Batch Name", RecMTNA_IF_OutputJournal."Journal Batch Name");
                        if RecOutputJournalLine.FindFirst() then begin
                            RecOutputJournalLine.DeleteAll();
                        end;
                    end;
                    RecMTNA_IF_OutputJournal."Processed datetime" := CurrentDateTime;
                    RecMTNA_IF_OutputJournal.Modify();
                    Commit();
                end;
                if ((MaxProcCount > 0) and (MaxProcCount <= proccessedCount)) then begin
                    break;
                end;
            until (RecMTNA_IF_OutputJournal.Next() = 0);

            if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Output Journal Process Post', RecMTNA_IF_OutputJournal.Plant, Format(RecMTNA_IF_OutputJournal."Entry No."),
                RecMTNA_IF_OutputJournal."Process start datetime", ErrorMessageText, pagMTNA_IF_OutputJournalErr.Caption, pagMTNA_IF_OutputJournalErr.ObjectId(false)) then begin
            end;
        end;
    end;

    [TryFunction]
    local procedure InsertItemJournalLine(RecMTNA_IF_OutputJournal: Record "MTNA_IF_OutputJournal"; var RecOutputJournalLine: Record "Item Journal Line")
    var
        RecProdOrderLine: Record "Prod. Order Line";
        RecProdOrderRoutingLine: Record "Prod. Order Routing Line";
        runTime: Decimal;
        CurrentJnlBatchName: Code[10];
        IntOperationNoRange: Integer;
        IntLineNo: Integer;
        IntProdOrderLineNo: Integer;
    begin
        CurrentJnlBatchName := 'OUTPUT';
        if not Evaluate(IntOperationNoRange, RecMTNA_IF_OutputJournal."Operation No.") then begin
            Error('The Operation No. is not a valid value.');
        end;
        RecProdOrderLine.Reset();
        RecProdOrderLine.SetRange("Prod. Order No.", RecMTNA_IF_OutputJournal."Order No.");
        if RecProdOrderLine.FindFirst() then begin
            IntProdOrderLineNo := RecProdOrderLine."Line No.";
        end
        else begin
            Error('The Order No is not a valid Production Order No.');
        end;
        RecProdOrderRoutingLine.Reset();
        RecProdOrderRoutingLine.SetRange("Prod. Order No.", RecMTNA_IF_OutputJournal."Order No.");
        //RecProdOrderRoutingLine.SetRange("Routing Reference No.", RecOutputJournalLine."Routing Reference No.");
        //RecProdOrderRoutingLine.SetRange("Operation No.", RecMTNA_IF_OutputJournal."Operation No.");
        RecProdOrderRoutingLine.SetFilter("Operation No.", '<%1', Format(IntOperationNoRange + 10));
        if RecProdOrderRoutingLine.IsEmpty() then begin
            Error('There is no related records for the Operation No.');
        end;
        IntLineNo := 0;
        RecProdOrderRoutingLine.FindSet();
        repeat
            IntLineNo += 10000;
            RecOutputJournalLine.Reset();
            RecOutputJournalLine.Init();
            /*The following steps can't be changed in order to insert and post the Item Journal Line successfully*/
            RecOutputJournalLine."Journal Template Name" := CurrentJnlBatchName;
            RecOutputJournalLine."Journal Batch Name" := RecMTNA_IF_OutputJournal."Journal Batch Name";
            RecOutputJournalLine."Posting Date" := RecMTNA_IF_OutputJournal."Posting date";
            RecOutputJournalLine.Validate("Posting Date");
            RecOutputJournalLine."Order Type" := RecOutputJournalLine."Order Type"::Production;
            RecOutputJournalLine."Order No." := RecMTNA_IF_OutputJournal."Order No.";
            RecOutputJournalLine.Validate("Order No.");
            RecOutputJournalLine.Validate("Entry Type", RecOutputJournalLine."Entry Type"::Output);
            RecOutputJournalLine."Item No." := RecMTNA_IF_OutputJournal."Item No.";
            RecOutputJournalLine.Validate("Item No.");
            RecOutputJournalLine."Line No." := IntLineNo;
            //RecOutputJournalLine."Operation No." := RecMTNA_IF_OutputJournal."Operation No.";
            RecOutputJournalLine."Operation No." := RecProdOrderRoutingLine."Operation No.";
            RecOutputJournalLine.Validate("Operation No.");
            RecOutputJournalLine."Type" := RecOutputJournalLine."Type"::"Machine Center";
            RecOutputJournalLine.Validate("Type");
            //RecOutputJournalLine."No." := RecMTNA_IF_OutputJournal."Machine Center Code";
            RecOutputJournalLine."No." := RecProdOrderRoutingLine."No.";
            RecOutputJournalLine.Validate("No.");
            /*The steps above can't be changed in order to insert and post the Item Journal Line successfully*/
            RecOutputJournalLine."Source No." := RecMTNA_IF_OutputJournal."Item No.";
            RecOutputJournalLine."Document No." := RecMTNA_IF_OutputJournal."Order No.";
            RecOutputJournalLine."Description" := RecMTNA_IF_OutputJournal."Primary record ID";
            RecOutputJournalLine."Location Code" := RecMTNA_IF_OutputJournal."Location Code";
            RecOutputJournalLine."Quantity" := RecMTNA_IF_OutputJournal."Output Quantity";
            RecOutputJournalLine."Source Code" := 'POINOUTJNL';
            RecOutputJournalLine."Source Type" := RecOutputJournalLine."Source Type"::Item;
            RecOutputJournalLine."Document Date" := RecMTNA_IF_OutputJournal."Posting date";
            RecOutputJournalLine."Order Line No." := IntProdOrderLineNo;
            RecOutputJournalLine."Bin Code" := RecMTNA_IF_OutputJournal."Bin Code";
            RecOutputJournalLine."Setup Time" := RecMTNA_IF_OutputJournal."Setup Time";
            RecOutputJournalLine."Output Quantity" := RecMTNA_IF_OutputJournal."Output Quantity";
            RecOutputJournalLine."Scrap Quantity" := RecMTNA_IF_OutputJournal."Scrap Quantity";
            RecOutputJournalLine."Scrap Code" := RecMTNA_IF_OutputJournal."Scrap Code";
            RecOutputJournalLine."Work Shift Code" := RecMTNA_IF_OutputJournal."Work Shift Code";
            RecOutputJournalLine.Validate("Location Code");
            RecOutputJournalLine.Validate("Quantity");
            RecOutputJournalLine.Validate("Order Line No.");
            RecOutputJournalLine.Validate("Bin Code");
            RecOutputJournalLine.Validate("Setup Time");
            RecOutputJournalLine.Validate("Output Quantity");
            RecOutputJournalLine.Validate("Scrap Quantity");
            RecOutputJournalLine.Validate("Scrap Code");
            runTime := Round(RecProdOrderRoutingLine."Run Time" * (RecMTNA_IF_OutputJournal."Output Quantity" + RecMTNA_IF_OutputJournal."Scrap Quantity") / RecProdOrderRoutingLine."Lot Size", 0.00001);
            RecOutputJournalLine."Run Time" := runTime;
            RecOutputJournalLine.Validate("Run Time");
            RecOutputJournalLine."Run Time (Base)" := runTime;
            RecOutputJournalLine.Validate("Run Time (Base)");
            /*2025/5/12 by Channing.zhou Add logic to set the Cap. Unit of Measure Code to SEC and check the Qty. per Cap. Unit of Measure value. Start*/
            RecOutputJournalLine."Cap. Unit of Measure Code" := 'SEC';
            RecOutputJournalLine.Validate("Cap. Unit of Measure Code");
            if RecOutputJournalLine."Qty. per Cap. Unit of Measure" <> 0.00028 then begin
                RecOutputJournalLine."Qty. per Cap. Unit of Measure" := 0.00028;
            end;
            /*2025/5/12 end*/
            RecOutputJournalLine.Insert(true);
        until RecProdOrderRoutingLine.Next() = 0;
    end;
}

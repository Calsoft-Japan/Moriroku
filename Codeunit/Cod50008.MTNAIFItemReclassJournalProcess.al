codeunit 50008 MTNAIFItemReclasJournalProcess
{
    //CS 2024/9/5 Channing.Zhou FDD307 CodeUnit for MTNA IF Item Reclass Journal Process
    //CS 2025/10/21 Channing.Zhou FDD300 V7 Change the notification email contents, add error information page url.

    var
        CurrentJnlTemplateName: Code[10];

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
        RecMTNA_IF_ItemReclassJournal: Record "MTNA_IF_ItemReclassJournal";
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        MaxProcCount: Integer;
    begin
        RecMTNA_IF_ItemReclassJournal.Reset();
        RecMTNA_IF_ItemReclassJournal.SetRange(Status, RecMTNA_IF_ItemReclassJournal.Status::Ready);
        if RecMTNA_IF_ItemReclassJournal.FindFirst() then begin
            MaxProcCount := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Item reclass journal");
            if RecMTNAIFConfiguration.FindFirst() then begin
                MaxProcCount := RecMTNAIFConfiguration."Max. records to process";
            end;
            ProcessItemReclassJournalData(RecMTNA_IF_ItemReclassJournal, MaxProcCount, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcessItemReclassJournalData(var RecMTNA_IF_ItemReclassJournal: Record "MTNA_IF_ItemReclassJournal"; MaxProcCount: Integer; var ErrorRecCount: Integer)
    var
        RecItemReclassJournalLine: Record "Item Journal Line";
        ErrorMessageText: Text;
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
        RecReservationEntry: Record "Reservation Entry";
        CuItemJnlPost: Codeunit "Item Jnl.-Post";
        pagMTNA_IF_ItemReclassJournalErr: Page "MTNA_IF_ItemReclassJournalErr";
        RecRef: RecordRef;
        proccessedCount: Integer;
    begin
        ErrorRecCount := 0;
        proccessedCount := 0;
        CurrentJnlTemplateName := 'TRANSFER';
        if RecMTNA_IF_ItemReclassJournal.FindFirst() then begin
            repeat
                proccessedCount += 1;
                if RecMTNA_IF_ItemReclassJournal.Status = RecMTNA_IF_ItemReclassJournal.Status::Ready then begin
                    RecMTNA_IF_ItemReclassJournal."Process start datetime" := CurrentDateTime;
                    RecItemReclassJournalLine.Reset();
                    RecItemReclassJournalLine.SetRange("Journal Batch Name", RecMTNA_IF_ItemReclassJournal."Journal Batch Name".ToUpper());
                    if not RecItemReclassJournalLine.IsEmpty() then begin
                        RecItemReclassJournalLine.FindSet();
                        repeat
                            RecReservationEntry.Reset();
                            RecReservationEntry.SetRange("Source Type", Database::"Item Journal Line");
                            RecReservationEntry.SetRange("Source Subtype", RecItemReclassJournalLine."Entry Type"::Transfer.AsInteger());
                            RecReservationEntry.SetRange("Source ID", CurrentJnlTemplateName);
                            RecReservationEntry.SetRange("Source Batch Name", RecMTNA_IF_ItemReclassJournal."Journal Batch Name");
                            if not RecReservationEntry.IsEmpty() then begin
                                RecReservationEntry.DeleteAll(true);
                            end;
                        until RecItemReclassJournalLine.Next() = 0;
                        RecItemReclassJournalLine.DeleteAll(true);
                    end;
                    RecItemReclassJournalLine.Reset();
                    Clear(RecItemReclassJournalLine);
                    if InsertItemJournalLine(RecMTNA_IF_ItemReclassJournal, RecItemReclassJournalLine) then begin
                        Commit();
                        if CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", RecItemReclassJournalLine) then begin
                            RecMTNA_IF_ItemReclassJournal.Status := RecMTNA_IF_ItemReclassJournal.Status::Completed;
                            RecMTNA_IF_ItemReclassJournal.Modify();
                        end
                        else begin
                            ErrorMessageText := GetLastErrorText();
                            RecMTNA_IF_ItemReclassJournal.Status := RecMTNA_IF_ItemReclassJournal.Status::Error;
                            RecMTNA_IF_ItemReclassJournal.SetErrormessage('Error occurred when posting Item Journal Line. The detailed error message is: ' + ErrorMessageText);
                            RecMTNA_IF_ItemReclassJournal.Modify();
                            RecReservationEntry.Reset();
                            RecReservationEntry.SetRange("Source Type", Database::"Item Journal Line");
                            RecReservationEntry.SetRange("Source Subtype", RecItemReclassJournalLine."Entry Type"::Transfer.AsInteger());
                            RecReservationEntry.SetRange("Source ID", CurrentJnlTemplateName);
                            RecReservationEntry.SetRange("Source Batch Name", RecMTNA_IF_ItemReclassJournal."Journal Batch Name");
                            if not RecReservationEntry.IsEmpty() then begin
                                RecReservationEntry.DeleteAll(true);
                            end;
                            RecItemReclassJournalLine.Delete(true);
                            RecRef.GetTable(RecMTNA_IF_ItemReclassJournal);
                            if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Item Reclass Journal Process Post', RecMTNA_IF_ItemReclassJournal.Plant, Format(RecMTNA_IF_ItemReclassJournal."Entry No."),
                                RecMTNA_IF_ItemReclassJournal."Process start datetime", ErrorMessageText, pagMTNA_IF_ItemReclassJournalErr.Caption, pagMTNA_IF_ItemReclassJournalErr.ObjectId(false), RecRef) then begin
                            end;
                            ErrorRecCount += 1;
                        end;
                    end
                    else begin
                        ErrorMessageText := GetLastErrorText();
                        RecMTNA_IF_ItemReclassJournal.Status := RecMTNA_IF_ItemReclassJournal.Status::Error;
                        RecMTNA_IF_ItemReclassJournal.SetErrormessage('Error occurred when inserting Item Journal Line. The detailed error message is: ' + ErrorMessageText);
                        RecMTNA_IF_ItemReclassJournal.Modify();
                        RecRef.GetTable(RecMTNA_IF_ItemReclassJournal);
                        if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Item Reclass Journal Process Insert', RecMTNA_IF_ItemReclassJournal.Plant, Format(RecMTNA_IF_ItemReclassJournal."Entry No."),
                            RecMTNA_IF_ItemReclassJournal."Process start datetime", ErrorMessageText, pagMTNA_IF_ItemReclassJournalErr.Caption, pagMTNA_IF_ItemReclassJournalErr.ObjectId(false), RecRef) then begin
                        end;
                        ErrorRecCount += 1;
                    end;
                    RecMTNA_IF_ItemReclassJournal."Processed datetime" := CurrentDateTime;
                    RecMTNA_IF_ItemReclassJournal.Modify();
                    Commit();
                end;
                if ((MaxProcCount > 0) and (MaxProcCount <= proccessedCount)) then begin
                    break;
                end;
            until RecMTNA_IF_ItemReclassJournal.Next() = 0;
        end;
    end;

    [TryFunction]
    local procedure InsertItemJournalLine(RecMTNA_IF_ItemJournal: Record "MTNA_IF_ItemReclassJournal"; var RecItemReclassJournalLine: Record "Item Journal Line")
    var
        RecItem: Record Item;
        RecItemUom: Record "Item Unit of Measure";
        QtyperUnitofMeasure: Decimal;
        RecReservationEntry: Record "Reservation Entry";
        RecItemJnlBat: Record "Item Journal Batch";
        CUNoSeries: Codeunit "No. Series";
        NoSeries: Code[20];
        NextDocNo: Code[20];
    begin
        RecItemReclassJournalLine.Reset();
        RecItemReclassJournalLine.Init();
        /*The following steps can't be changed in order to insert and post the Item Journal Line successfully*/
        RecItemReclassJournalLine."Journal Template Name" := CurrentJnlTemplateName;
        RecItemReclassJournalLine."Journal Batch Name" := RecMTNA_IF_ItemJournal."Journal Batch Name";
        RecItemReclassJournalLine."Posting Date" := RecMTNA_IF_ItemJournal."Posting date";
        RecItemReclassJournalLine.Validate("Posting Date");
        RecItemReclassJournalLine.Validate("Entry Type", RecItemReclassJournalLine."Entry Type"::Transfer);
        RecItemReclassJournalLine."Item No." := RecMTNA_IF_ItemJournal."Item No.";
        RecItemReclassJournalLine.Validate("Item No.");
        RecItemReclassJournalLine."Line No." := 10000;
        /*The steps above can't be changed in order to insert and post the Item Journal Line successfully*/
        RecItem.Reset();
        RecItem.SetRange("No.", RecItemReclassJournalLine."Item No.");
        if RecItem.FindFirst() then begin
            RecItemReclassJournalLine."Gen. Prod. Posting Group" := RecItem."Gen. Prod. Posting Group";
        end;

        //Leon 2/7/2025 ===If [Document No.] of IF table is NOT blank, set the [Document No.] of IF table
        if RecMTNA_IF_ItemJournal."Document No.".Trim() = '' then begin //Else use NoSeries
            RecItemJnlBat.Reset();
            RecItemJnlBat.SetRange("Journal Template Name", CurrentJnlTemplateName);
            RecItemJnlBat.SetRange(Name, RecMTNA_IF_ItemJournal."Journal Batch Name");
            if not RecItemJnlBat.FindFirst() then begin
                Error('Can not get the No. Series.');
            end
            else begin
                NoSeries := RecItemJnlBat."No. Series";
            end;
            if NoSeries = '' then begin
                Error('You cannot get a No. Series line with empty No. Series Code.');
            end;
            CUNoSeries.TestAutomatic(NoSeries);
            NextDocNo := CUNoSeries.PeekNextNo(NoSeries);
        end
        else begin //Leon 2/7/2025 ===If [Document No.] of IF table is NOT blank, set the [Document No.] of IF table
            NextDocNo := RecMTNA_IF_ItemJournal."Document No.".Trim();
        end;
        RecItemReclassJournalLine."Document No." := NextDocNo;
        //RecItemReclassJournalLine."Document No." := RecMTNA_IF_ItemJournal."Document No.";
        RecItemReclassJournalLine."Description" := RecMTNA_IF_ItemJournal."Primary record ID";
        RecItemReclassJournalLine."External Document No." := RecMTNA_IF_ItemJournal."Primary record ID";
        RecItemReclassJournalLine."Location Code" := RecMTNA_IF_ItemJournal."Location Code";
        RecItemReclassJournalLine."New Location Code" := RecMTNA_IF_ItemJournal."New Location Code";
        RecItemReclassJournalLine."Quantity" := RecMTNA_IF_ItemJournal."Quantity";
        RecItemReclassJournalLine."Source Code" := 'RECLASSJNL';
        RecItemReclassJournalLine."Document Date" := RecMTNA_IF_ItemJournal."Posting date";
        RecItemReclassJournalLine."Bin Code" := RecMTNA_IF_ItemJournal."Bin Code";
        RecItemReclassJournalLine."New Bin Code" := RecMTNA_IF_ItemJournal."New Bin Code";
        if RecMTNA_IF_ItemJournal."Gen Bus Posting Group" <> '' then begin
            RecItemReclassJournalLine."Gen. Bus. Posting Group" := RecMTNA_IF_ItemJournal."Gen Bus Posting Group";
        end;
        RecItemReclassJournalLine.Validate("Location Code");
        RecItemReclassJournalLine.Validate("New Location Code");
        RecItemReclassJournalLine.Validate("Quantity");
        RecItemReclassJournalLine.Validate("Bin Code");
        RecItemReclassJournalLine.Validate("New Bin Code");
        RecItemReclassJournalLine.Insert(true);
        if (RecMTNA_IF_ItemJournal."Lot No." <> '') then begin
            RecItemReclassJournalLine."Lot No." := RecMTNA_IF_ItemJournal."Lot No.";
            RecItemReclassJournalLine."New Lot No." := RecMTNA_IF_ItemJournal."Lot No.";
            RecItemUom.Reset();
            RecItemUom.SetRange("Item No.", RecItemReclassJournalLine."Item No.");
            RecItemUom.SetRange(Code, RecItemReclassJournalLine."Unit of Measure Code");
            if RecItemUom.FindFirst() then begin
                QtyperUnitofMeasure := RecItemUom."Qty. per Unit of Measure";
            end
            else begin
                QtyperUnitofMeasure := 1;
            end;
            RecReservationEntry.Reset();
            RecReservationEntry.SetRange("Transferred from Entry No.", 0);
            RecReservationEntry.SetSourceFilter(Database::"Item Journal Line", RecItemReclassJournalLine."Entry Type".AsInteger(), RecItemReclassJournalLine."Journal Template Name", RecItemReclassJournalLine."Line No.", false);
            RecReservationEntry.SetSourceFilter(RecItemReclassJournalLine."Journal Batch Name", 0);
            RecReservationEntry.SetTrackingFilterFromItemJnlLine(RecItemReclassJournalLine);
            if RecReservationEntry.FindFirst() then begin
                RecReservationEntry."Qty. per Unit of Measure" := QtyperUnitofMeasure;
                RecReservationEntry.Quantity := -RecItemReclassJournalLine."Quantity";
                RecReservationEntry.Validate("Quantity (Base)", RecItemReclassJournalLine."Quantity" * QtyperUnitofMeasure);
                RecReservationEntry.Modify();
            end
            else begin
                RecReservationEntry.Init();
                RecReservationEntry."Item No." := RecItemReclassJournalLine."Item No.";
                RecReservationEntry."Location Code" := RecItemReclassJournalLine."Location Code";
                RecReservationEntry."Reservation Status" := RecReservationEntry."Reservation Status"::Prospect;
                RecReservationEntry."Source Type" := Database::"Item Journal Line";
                RecReservationEntry."Source Subtype" := RecItemReclassJournalLine."Entry Type".AsInteger();
                RecReservationEntry."Source ID" := 'TRANSFER';
                RecReservationEntry."Source Batch Name" := RecItemReclassJournalLine."Journal Batch Name";
                RecReservationEntry."Source Ref. No." := RecItemReclassJournalLine."Line No.";
                RecReservationEntry."Qty. per Unit of Measure" := QtyperUnitofMeasure;
                RecReservationEntry.Quantity := -RecItemReclassJournalLine."Quantity";
                RecReservationEntry.Validate("Quantity (Base)", -RecItemReclassJournalLine."Quantity" * QtyperUnitofMeasure);
                RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot No.";
                RecReservationEntry."Lot No." := RecItemReclassJournalLine."Lot No.";
                RecReservationEntry."New Lot No." := RecItemReclassJournalLine."Lot No.";
                RecReservationEntry.Insert(true);
            end;
            RecItemReclassJournalLine.Validate("Lot No.");
            RecItemReclassJournalLine.Validate("New Lot No.");
        end;
    end;
}

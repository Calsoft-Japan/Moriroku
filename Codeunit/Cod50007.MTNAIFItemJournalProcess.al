codeunit 50007 MTNAIFItemJournalProcess
{
    //CS 2024/9/5 Channing.Zhou FDD307 CodeUnit for MTNA IF Item Journal Process
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
        RecMTNA_IF_ItemJournal: Record "MTNA_IF_ItemJournal";
    begin
        RecMTNA_IF_ItemJournal.Reset();
        RecMTNA_IF_ItemJournal.SetRange(Status, RecMTNA_IF_ItemJournal.Status::Ready);
        if RecMTNA_IF_ItemJournal.FindFirst() then begin
            ProcessItemJournalData(RecMTNA_IF_ItemJournal, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcessItemJournalData(var RecMTNA_IF_ItemJournal: Record "MTNA_IF_ItemJournal"; var ErrorRecCount: Integer)
    var
        RecItemJournalLine: Record "Item Journal Line";
        ErrorMessageText: Text;
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
        RecReservationEntry: Record "Reservation Entry";
        pagMTNA_IF_ItemJournalErr: Page "MTNA_IF_ItemJournalErr";
        RecRef: RecordRef;
    begin
        ErrorRecCount := 0;
        CurrentJnlTemplateName := 'Item';
        if RecMTNA_IF_ItemJournal.FindFirst() then begin
            repeat
                if RecMTNA_IF_ItemJournal.Status = RecMTNA_IF_ItemJournal.Status::Ready then begin
                    RecMTNA_IF_ItemJournal."Process start datetime" := CurrentDateTime;
                    RecItemJournalLine.Reset();
                    RecItemJournalLine.SetRange("Journal Batch Name", RecMTNA_IF_ItemJournal."Journal Batch Name");
                    if not RecItemJournalLine.IsEmpty() then begin
                        RecItemJournalLine.FindSet();
                        repeat
                            RecReservationEntry.Reset();
                            RecReservationEntry.SetRange("Source Type", Database::"Item Journal Line");
                            RecReservationEntry.SetRange("Source ID", CurrentJnlTemplateName);
                            RecReservationEntry.SetRange("Source Batch Name", RecMTNA_IF_ItemJournal."Journal Batch Name");
                            if not RecReservationEntry.IsEmpty() then begin
                                RecReservationEntry.DeleteAll(true);
                            end;
                        until RecItemJournalLine.Next() = 0;
                        RecItemJournalLine.DeleteAll(true);
                    end;
                    RecItemJournalLine.Reset();
                    Clear(RecItemJournalLine);
                    if InsertItemJournalLine(RecMTNA_IF_ItemJournal, RecItemJournalLine) then begin
                        Commit();
                        if CODEUNIT.Run(CODEUNIT::"Item Jnl.-Post Batch", RecItemJournalLine) then begin
                            RecMTNA_IF_ItemJournal.Status := RecMTNA_IF_ItemJournal.Status::Completed;
                            RecMTNA_IF_ItemJournal.Modify();
                        end
                        else begin
                            ErrorMessageText := GetLastErrorText();
                            RecMTNA_IF_ItemJournal.Status := RecMTNA_IF_ItemJournal.Status::Error;
                            RecMTNA_IF_ItemJournal.SetErrormessage('Error occurred when posting Item Journal Line. The detailed error message is: ' + ErrorMessageText);
                            RecMTNA_IF_ItemJournal.Modify();
                            RecReservationEntry.Reset();
                            RecReservationEntry.SetRange("Source Type", Database::"Item Journal Line");
                            RecReservationEntry.SetRange("Source ID", CurrentJnlTemplateName);
                            RecReservationEntry.SetRange("Source Batch Name", RecMTNA_IF_ItemJournal."Journal Batch Name");
                            if not RecReservationEntry.IsEmpty() then begin
                                RecReservationEntry.DeleteAll(true);
                            end;
                            RecItemJournalLine.Delete(true);
                            RecRef.GetTable(RecMTNA_IF_ItemJournal);
                            if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Item Journal Process Post', RecMTNA_IF_ItemJournal.Plant, Format(RecMTNA_IF_ItemJournal."Entry No."),
                                RecMTNA_IF_ItemJournal."Process start datetime", ErrorMessageText, pagMTNA_IF_ItemJournalErr.Caption, pagMTNA_IF_ItemJournalErr.ObjectId(false), RecRef) then begin
                            end;
                            ErrorRecCount += 1;
                        end;
                    end
                    else begin
                        ErrorMessageText := GetLastErrorText();
                        RecMTNA_IF_ItemJournal.Status := RecMTNA_IF_ItemJournal.Status::Error;
                        RecMTNA_IF_ItemJournal.SetErrormessage('Error occurred when inserting Item Journal Line. The detailed error message is: ' + ErrorMessageText);
                        RecMTNA_IF_ItemJournal.Modify();
                        RecRef.GetTable(RecMTNA_IF_ItemJournal);
                        if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Item Journal Process Insert', RecMTNA_IF_ItemJournal.Plant, Format(RecMTNA_IF_ItemJournal."Entry No."),
                            RecMTNA_IF_ItemJournal."Process start datetime", ErrorMessageText, pagMTNA_IF_ItemJournalErr.Caption, pagMTNA_IF_ItemJournalErr.ObjectId(false), RecRef) then begin
                        end;
                        ErrorRecCount += 1;
                    end;
                    RecMTNA_IF_ItemJournal."Processed datetime" := CurrentDateTime;
                    RecMTNA_IF_ItemJournal.Modify();
                    Commit();
                end;
            until RecMTNA_IF_ItemJournal.Next() = 0;
        end;
    end;

    [TryFunction]
    local procedure InsertItemJournalLine(RecMTNA_IF_ItemJournal: Record "MTNA_IF_ItemJournal"; var RecItemJournalLine: Record "Item Journal Line")
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
        RecItemJournalLine.Reset();
        RecItemJournalLine.Init();
        /*The following steps can't be changed in order to insert and post the Item Journal Line successfully*/
        RecItemJournalLine."Journal Template Name" := CurrentJnlTemplateName;
        RecItemJournalLine."Journal Batch Name" := RecMTNA_IF_ItemJournal."Journal Batch Name";
        RecItemJournalLine."Posting Date" := RecMTNA_IF_ItemJournal."Posting date";
        RecItemJournalLine.Validate("Posting Date");
        RecItemJournalLine.Validate("Entry Type", RecMTNA_IF_ItemJournal."Entry Type");
        RecItemJournalLine."Item No." := RecMTNA_IF_ItemJournal."Item No.";
        RecItemJournalLine.Validate("Item No.");
        RecItemJournalLine."Line No." := 10000;
        /*The steps above can't be changed in order to insert and post the Item Journal Line successfully*/
        RecItem.Reset();
        RecItem.SetRange("No.", RecItemJournalLine."Item No.");
        if RecItem.FindFirst() then begin
            RecItemJournalLine."Gen. Prod. Posting Group" := RecItem."Gen. Prod. Posting Group";
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
            if NextDocNo = '' then begin
                Error('Can not get the next Document No.');
            end;
        end
        else begin //Leon 2/7/2025 ===If [Document No.] of IF table is NOT blank, set the [Document No.] of IF table
            NextDocNo := RecMTNA_IF_ItemJournal."Document No.".Trim();
        end;
        //RecItemJournalLine.docu
        RecItemJournalLine."Document No." := NextDocNo;
        //RecItemJournalLine."Document No." := RecMTNA_IF_ItemJournal."Document No.";
        RecItemJournalLine."Description" := RecMTNA_IF_ItemJournal."Primary record ID";
        RecItemJournalLine."External Document No." := RecMTNA_IF_ItemJournal."Primary record ID";
        RecItemJournalLine."Location Code" := RecMTNA_IF_ItemJournal."Location Code";
        RecItemJournalLine."Quantity" := RecMTNA_IF_ItemJournal."Quantity";
        RecItemJournalLine."Source Code" := 'ITEMJNL';
        RecItemJournalLine."Source Type" := RecItemJournalLine."Source Type"::Item;
        RecItemJournalLine."Document Date" := RecMTNA_IF_ItemJournal."Posting date";
        RecItemJournalLine."Bin Code" := RecMTNA_IF_ItemJournal."Bin Code";
        if RecMTNA_IF_ItemJournal."Gen Bus Posting Group" <> '' then begin
            RecItemJournalLine."Gen. Bus. Posting Group" := RecMTNA_IF_ItemJournal."Gen Bus Posting Group";
        end;
        RecItemJournalLine.Validate("Location Code");
        RecItemJournalLine.Validate("Quantity");
        RecItemJournalLine.Validate("Bin Code");
        RecItemJournalLine.Validate("Item No.");
        RecItemJournalLine.Insert(true);
        if (RecMTNA_IF_ItemJournal."Lot No." <> '') then begin
            RecItemJournalLine."Lot No." := RecMTNA_IF_ItemJournal."Lot No.";
            RecItemUom.Reset();
            RecItemUom.SetRange("Item No.", RecItemJournalLine."Item No.");
            RecItemUom.SetRange(Code, RecItemJournalLine."Unit of Measure Code");
            if RecItemUom.FindFirst() then begin
                QtyperUnitofMeasure := RecItemUom."Qty. per Unit of Measure";
            end
            else begin
                QtyperUnitofMeasure := 1;
            end;
            RecReservationEntry.Reset();
            RecReservationEntry.SetRange("Transferred from Entry No.", 0);
            RecReservationEntry.SetSourceFilter(Database::"Item Journal Line", RecItemJournalLine."Entry Type".AsInteger(), RecItemJournalLine."Journal Template Name", RecItemJournalLine."Line No.", false);
            RecReservationEntry.SetSourceFilter(RecItemJournalLine."Journal Batch Name", 0);
            RecReservationEntry.SetTrackingFilterFromItemJnlLine(RecItemJournalLine);
            if RecReservationEntry.FindFirst() then begin
                RecReservationEntry."Qty. per Unit of Measure" := QtyperUnitofMeasure;
                if RecItemJournalLine."Entry Type" = RecItemJournalLine."Entry Type"::"Positive Adjmt." then begin
                    RecReservationEntry.Quantity := RecItemJournalLine."Quantity";
                    RecReservationEntry.Validate("Quantity (Base)", RecItemJournalLine."Quantity" * QtyperUnitofMeasure);
                end
                else if RecItemJournalLine."Entry Type" = RecItemJournalLine."Entry Type"::"Negative Adjmt." then begin
                    RecReservationEntry.Quantity := -RecItemJournalLine."Quantity";
                    RecReservationEntry.Validate("Quantity (Base)", -RecItemJournalLine."Quantity" * QtyperUnitofMeasure);
                end;
                RecReservationEntry.Modify();
            end
            else begin
                RecReservationEntry.Init();
                RecReservationEntry."Item No." := RecItemJournalLine."Item No.";
                RecReservationEntry."Location Code" := RecItemJournalLine."Location Code";
                RecReservationEntry."Reservation Status" := RecReservationEntry."Reservation Status"::Surplus;
                RecReservationEntry."Source Type" := Database::"Item Journal Line";
                RecReservationEntry."Source Subtype" := RecItemJournalLine."Entry Type".AsInteger();
                RecReservationEntry."Source ID" := 'ITEM';
                RecReservationEntry."Source Batch Name" := RecItemJournalLine."Journal Batch Name";
                RecReservationEntry."Source Ref. No." := RecItemJournalLine."Line No.";
                RecReservationEntry."Qty. per Unit of Measure" := QtyperUnitofMeasure;
                RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot No.";
                RecReservationEntry."Lot No." := RecItemJournalLine."Lot No.";
                if RecItemJournalLine."Entry Type" = RecItemJournalLine."Entry Type"::"Positive Adjmt." then begin
                    RecReservationEntry.Quantity := RecItemJournalLine."Quantity";
                    RecReservationEntry.Validate("Quantity (Base)", RecItemJournalLine."Quantity" * QtyperUnitofMeasure);
                end
                else if RecItemJournalLine."Entry Type" = RecItemJournalLine."Entry Type"::"Negative Adjmt." then begin
                    RecReservationEntry.Quantity := -RecItemJournalLine."Quantity";
                    RecReservationEntry.Validate("Quantity (Base)", -RecItemJournalLine."Quantity" * QtyperUnitofMeasure);
                end;
                RecReservationEntry.Insert(true);
            end;
            RecItemJournalLine.Validate("Lot No.");
        end;
    end;
}

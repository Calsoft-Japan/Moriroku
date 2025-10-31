codeunit 50005 MTNAIFPurchaseReceivingProcess
{
    //CS 2024/9/5 Channing.Zhou FDD305 CodeUnit for MTNA IF Purchase Receiving Process
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
        RecMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        MaxProcCount: Integer;
    begin
        RecMTNA_IF_PurchaseReceiving.Reset();
        RecMTNA_IF_PurchaseReceiving.SetRange(Status, RecMTNA_IF_PurchaseReceiving.Status::Ready);
        if RecMTNA_IF_PurchaseReceiving.FindFirst() then begin
            MaxProcCount := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Purchase receiving");
            if RecMTNAIFConfiguration.FindFirst() then begin
                MaxProcCount := RecMTNAIFConfiguration."Max. records to process";
            end;
            ProcessPurchaseReceivingData(RecMTNA_IF_PurchaseReceiving, MaxProcCount, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcessPurchaseReceivingData(var RecMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving"; MaxProcCount: Integer; var ErrorRecCount: Integer)
    var
        RecPOHeaderLine: Record "Purchase Header";
        RecPOLines: Record "Purchase Line";
        ErrorMessageText: Text;
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
        RecReservationEntry: Record "Reservation Entry";
        pagMTNA_IF_PurchaseReceivingErr: Page "MTNA_IF_PurchaseReceivingErr";
        proccessedCount: Integer;
    begin
        ErrorRecCount := 0;
        proccessedCount := 0;
        if RecMTNA_IF_PurchaseReceiving.FindFirst() then begin
            repeat
                proccessedCount += 1;
                if RecMTNA_IF_PurchaseReceiving.Status = RecMTNA_IF_PurchaseReceiving.Status::Ready then begin
                    RecMTNA_IF_PurchaseReceiving."Process start datetime" := CurrentDateTime;

                    RecPOHeaderLine.Reset();
                    RecPOHeaderLine.SetRange("Document Type", RecPOHeaderLine."Document Type"::Order);
                    RecPOHeaderLine.SetRange("No.", RecMTNA_IF_PurchaseReceiving."Order No.");
                    if not RecPOHeaderLine.FindFirst() then begin
                        ErrorMessageText := RecMTNA_IF_PurchaseReceiving."Order No." + ' no found.';
                        PurchaseReceivingErrorMessage(RecMTNA_IF_PurchaseReceiving, ErrorMessageText);
                        ErrorRecCount += 1;
                    end
                    else begin
                        if UpdatePurchaseHeader(RecMTNA_IF_PurchaseReceiving, RecPOHeaderLine, RecPOLines) then begin
                            Commit();
                            if PostCurPurchRecv(RecPOHeaderLine) then begin
                                RecPOLines.Reset();
                                RecPOLines.SetRange("Document Type", RecPOHeaderLine."Document Type"::Order);
                                RecPOLines.SetRange("Document No.", RecMTNA_IF_PurchaseReceiving."Order No.");
                                RecPOLines.SetRange("Line No.", RecMTNA_IF_PurchaseReceiving."Line No.");
                                if RecPOLines.FindFirst() then begin
                                    RecReservationEntry.Reset();
                                    RecReservationEntry.SetRange("Item No.", RecPOLines."No.");
                                    RecReservationEntry.SetRange("Source Ref. No.", RecMTNA_IF_PurchaseReceiving."Line No.");
                                    RecReservationEntry.SetRange("Lot No.", RecMTNA_IF_PurchaseReceiving."Lot Number");
                                    RecReservationEntry.SetRange("Source ID", RecMTNA_IF_PurchaseReceiving."Order No.");
                                    if RecReservationEntry.FindFirst() then begin
                                        RecReservationEntry.DeleteAll();
                                    end;
                                end;
                                RecMTNA_IF_PurchaseReceiving.Status := RecMTNA_IF_PurchaseReceiving.Status::Completed;
                                RecMTNA_IF_PurchaseReceiving.Modify();
                            end
                            else begin
                                ErrorMessageText := GetLastErrorText();
                                PurchaseReceivingErrorMessage(RecMTNA_IF_PurchaseReceiving, ErrorMessageText);
                                ErrorRecCount += 1;
                            end;
                        end
                        else begin
                            ErrorMessageText := GetLastErrorText();
                            PurchaseReceivingErrorMessage(RecMTNA_IF_PurchaseReceiving, ErrorMessageText);
                            ErrorRecCount += 1;
                        end;
                        RecMTNA_IF_PurchaseReceiving."Processed datetime" := CurrentDateTime;
                        RecMTNA_IF_PurchaseReceiving.Modify();
                    end;
                end;
                if ((MaxProcCount > 0) and (MaxProcCount <= proccessedCount)) then begin
                    break;
                end;
            until RecMTNA_IF_PurchaseReceiving.Next() = 0;
        end;
    end;

    [TryFunction]
    local procedure UpdatePurchaseHeader(RecMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving"; var RecPOHeaderLine: Record "Purchase Header"; var RecPOLines: Record "Purchase Line")
    var
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        RecItem: Record Item;
        RecItemUom: Record "Item Unit of Measure";
        QtyperUnitofMeasure: Decimal;
        RecReservationEntry: Record "Reservation Entry";
    begin
        RecPOHeaderLine.Reset();
        RecPOHeaderLine.SetRange("Document Type", RecPOHeaderLine."Document Type"::Order);
        RecPOHeaderLine.SetRange("No.", RecMTNA_IF_PurchaseReceiving."Order No.");
        if RecPOHeaderLine.FindFirst() then begin
            RecPOHeaderLine.Validate("Posting Date", RecMTNA_IF_PurchaseReceiving."Posting Date");
            RecPOHeaderLine.Validate("Vendor Shipment No.", RecMTNA_IF_PurchaseReceiving."Vendor Shipment No.");
            RecPOHeaderLine.Validate("Document Date", RecMTNA_IF_PurchaseReceiving."Posting Date");
            RecPOHeaderLine.Receive := true;
            RecPOHeaderLine.Ship := false;
            RecPOHeaderLine.Invoice := false;
            RecPOHeaderLine.Modify();
            if RecPOHeaderLine.Status = RecPOHeaderLine.Status::Released then
                ReleasePurchDoc.PerformManualReopen(RecPOHeaderLine);
            RecPOLines.Reset();
            RecPOLines.SetRange("Document Type", RecPOHeaderLine."Document Type"::Order);
            RecPOLines.SetRange("Document No.", RecMTNA_IF_PurchaseReceiving."Order No.");
            RecPOLines.ModifyAll("Qty. to Receive", 0, true);
            RecPOLines.ModifyAll("Qty. to Receive (Base)", 0, true);
            RecPOLines.ModifyAll("Qty. to Invoice", 0, true);
            RecPOLines.ModifyAll("Qty. to Invoice (Base)", 0, true);

            RecPOLines.Reset();
            RecPOLines.SetRange("Document Type", RecPOHeaderLine."Document Type"::Order);
            RecPOLines.SetRange("Document No.", RecMTNA_IF_PurchaseReceiving."Order No.");
            RecPOLines.SetRange("Line No.", RecMTNA_IF_PurchaseReceiving."Line No.");
            if RecPOLines.FindFirst() then begin
                if (RecPOLines."Quantity Received" = RecPOLines."Quantity Invoiced") and (RecPOLines."Location Code" <> RecMTNA_IF_PurchaseReceiving."Location Code") or (RecPOLines."Location Code" = RecMTNA_IF_PurchaseReceiving."Location Code") or (RecPOLines."Location Code" = '') then begin
                    RecPOLines.Validate("Location Code", RecMTNA_IF_PurchaseReceiving."Location Code");
                    RecPOLines.Validate("Bin Code", RecMTNA_IF_PurchaseReceiving."Bin Code");
                end;
                RecPOLines.Validate("Qty. to Receive", RecMTNA_IF_PurchaseReceiving."Qty. to Receive");
                RecPOLines.Modify();
            end;

            if RecMTNA_IF_PurchaseReceiving."Lot Number" <> '' then begin
                if RecPOLines.FindFirst() then begin
                    RecItem.Get(RecPOLines."No.");
                    RecItem.TestField("Item Tracking Code");

                    RecItemUom.Reset();
                    RecItemUom.SetRange("Item No.", RecPOLines."No.");
                    RecItemUom.SetRange(Code, RecPOLines."Unit of Measure Code");
                    if RecItemUom.FindFirst() then begin
                        QtyperUnitofMeasure := RecItemUom."Qty. per Unit of Measure";
                    end;

                    RecReservationEntry.Reset();
                    RecReservationEntry.SetRange("Item No.", RecPOLines."No.");
                    RecReservationEntry.SetRange("Source Ref. No.", RecMTNA_IF_PurchaseReceiving."Line No.");
                    RecReservationEntry.SetRange("Lot No.", RecMTNA_IF_PurchaseReceiving."Lot Number");
                    RecReservationEntry.SetRange("Source ID", RecMTNA_IF_PurchaseReceiving."Order No.");
                    if RecReservationEntry.FindFirst() then begin
                        RecReservationEntry.DeleteAll();
                    end;
                    RecReservationEntry.Reset();
                    RecReservationEntry.Init();
                    RecReservationEntry."Item No." := RecPOLines."No.";
                    RecReservationEntry."Location Code" := RecPOLines."Location Code";
                    RecReservationEntry."Reservation Status" := RecReservationEntry."Reservation Status"::Surplus;
                    RecReservationEntry."Source Type" := 39;
                    RecReservationEntry."Source Subtype" := 1;
                    RecReservationEntry."Source ID" := RecMTNA_IF_PurchaseReceiving."Order No.";
                    RecReservationEntry."Source Ref. No." := RecMTNA_IF_PurchaseReceiving."Line No.";
                    RecReservationEntry."Qty. per Unit of Measure" := QtyperUnitofMeasure;
                    RecReservationEntry.Quantity := RecMTNA_IF_PurchaseReceiving."Qty. to Receive";
                    RecReservationEntry.Validate("Quantity (Base)", RecMTNA_IF_PurchaseReceiving."Qty. to Receive" * QtyperUnitofMeasure);
                    RecReservationEntry."Item Tracking" := RecReservationEntry."Item Tracking"::"Lot No.";
                    RecReservationEntry."Lot No." := RecMTNA_IF_PurchaseReceiving."Lot Number";
                    RecReservationEntry.Insert();
                end;

            end;
        end;
    end;


    local procedure PostCurPurchRecv(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        ReleasePurchDoc: Codeunit "Release Purchase Document";
    begin
        ReleasePurchDoc.PerformManualReopen(PurchaseHeader);
        if CODEUNIT.Run(CODEUNIT::"Purch.-Post", PurchaseHeader) then begin
            exit(true);
        end;
        exit(false);
    end;

    [TryFunction]
    local procedure PurchaseReceivingErrorMessage(var RecMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving"; ErrorMessageText: Text)
    var
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
        pagMTNA_IF_PurchaseReceivingErr: Page "MTNA_IF_PurchaseReceivingErr";
    begin
        RecMTNA_IF_PurchaseReceiving.Status := RecMTNA_IF_PurchaseReceiving.Status::Error;
        RecMTNA_IF_PurchaseReceiving.SetErrormessage('Error occurred when updating Purchase Receiving. The detailed error message is: ' + ErrorMessageText);
        RecMTNA_IF_PurchaseReceiving.Modify();
        if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Purchase Receiving Process update', RecMTNA_IF_PurchaseReceiving.Plant, Format(RecMTNA_IF_PurchaseReceiving."Entry No."),
            RecMTNA_IF_PurchaseReceiving."Process start datetime", ErrorMessageText, pagMTNA_IF_PurchaseReceivingErr.Caption, pagMTNA_IF_PurchaseReceivingErr.ObjectId(false)) then begin
        end;
    end;


}

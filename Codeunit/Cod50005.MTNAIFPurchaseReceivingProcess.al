codeunit 50005 MTNAIFPurchaseReceivingProcess
{
    //CS 2024/9/5 Channing.Zhou FDD305 CodeUnit for MTNA IF Purchase Receiving Process
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
    begin
        RecMTNA_IF_PurchaseReceiving.Reset();
        RecMTNA_IF_PurchaseReceiving.SetRange(Status, RecMTNA_IF_PurchaseReceiving.Status::Ready);
        if RecMTNA_IF_PurchaseReceiving.FindFirst() then begin
            ProcessPurchaseReceivingData(RecMTNA_IF_PurchaseReceiving, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcessPurchaseReceivingData(var RecMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving"; var ErrorRecCount: Integer)
    var
        RecPOHeaderLine: Record "Purchase Header";
        TempPOHeader: Record "Purchase Header" temporary;
        RecPOLines: Record "Purchase Line";
        ErrorMessageText: Text;
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
        TempMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
        ModifyMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
        RecReservationEntry: Record "Reservation Entry";
    begin
        ErrorRecCount := 0;

        if RecMTNA_IF_PurchaseReceiving.FindFirst() then begin
            repeat
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
                        if UpdatePurchaseHeader(RecMTNA_IF_PurchaseReceiving, RecPOHeaderLine, RecPOLines, TempPOHeader) then begin
                        end
                        else begin
                            ErrorMessageText := GetLastErrorText();
                            ModifyMTNA_IF_PurchaseReceiving.Reset();
                            ModifyMTNA_IF_PurchaseReceiving.SetRange(status, ModifyMTNA_IF_PurchaseReceiving.Status::Ready);
                            ModifyMTNA_IF_PurchaseReceiving.SetRange("Order No.", RecMTNA_IF_PurchaseReceiving."Order No.");
                            if ModifyMTNA_IF_PurchaseReceiving.FindFirst() then begin
                                repeat
                                    ModifyMTNA_IF_PurchaseReceiving.Status := ModifyMTNA_IF_PurchaseReceiving.Status::Error;
                                    ModifyMTNA_IF_PurchaseReceiving.SetErrormessage('Error occurred when updating Purchase Receiving. The detailed error message is: ' + ErrorMessageText);
                                    ModifyMTNA_IF_PurchaseReceiving.Modify();
                                    if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Purchase Receiving Process update', ModifyMTNA_IF_PurchaseReceiving.Plant, Format(ModifyMTNA_IF_PurchaseReceiving."Entry No."),
                                        ModifyMTNA_IF_PurchaseReceiving."Process start datetime", ErrorMessageText) then begin
                                    end;
                                    ErrorRecCount += 1;
                                until ModifyMTNA_IF_PurchaseReceiving.Next() = 0;
                            end;
                        end;
                        RecMTNA_IF_PurchaseReceiving."Processed datetime" := CurrentDateTime;
                        RecMTNA_IF_PurchaseReceiving.Modify();
                    end;
                end;
            until RecMTNA_IF_PurchaseReceiving.Next() = 0
        end;

        if RecMTNA_IF_PurchaseReceiving.FindFirst() then begin
            repeat
                if RecMTNA_IF_PurchaseReceiving.Status = RecMTNA_IF_PurchaseReceiving.Status::Ready then begin
                    TempPOHeader.Reset();
                    TempPOHeader.SetRange("No.", RecMTNA_IF_PurchaseReceiving."Order No.");
                    TempPOHeader.SetRange(Invoice, false);
                    if TempPOHeader.FindFirst() then begin
                        Commit();
                        if Code(RecPOHeaderLine) then begin
                            TempPOHeader.Invoice := true;
                            TempPOHeader.Modify();

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

                            ModifyMTNA_IF_PurchaseReceiving.Reset();
                            ModifyMTNA_IF_PurchaseReceiving.SetRange(status, ModifyMTNA_IF_PurchaseReceiving.Status::Ready);
                            ModifyMTNA_IF_PurchaseReceiving.SetRange("Order No.", RecMTNA_IF_PurchaseReceiving."Order No.");
                            ModifyMTNA_IF_PurchaseReceiving.ModifyAll(Status, RecMTNA_IF_PurchaseReceiving.Status::Completed);
                        end
                        else begin
                            ErrorMessageText := GetLastErrorText();
                            ModifyMTNA_IF_PurchaseReceiving.Reset();
                            ModifyMTNA_IF_PurchaseReceiving.SetRange(status, ModifyMTNA_IF_PurchaseReceiving.Status::Ready);
                            ModifyMTNA_IF_PurchaseReceiving.SetRange("Order No.", RecMTNA_IF_PurchaseReceiving."Order No.");
                            if ModifyMTNA_IF_PurchaseReceiving.FindFirst() then begin
                                repeat
                                    ModifyMTNA_IF_PurchaseReceiving.Status := ModifyMTNA_IF_PurchaseReceiving.Status::Error;
                                    ModifyMTNA_IF_PurchaseReceiving.SetErrormessage('Error occurred when posting Purchase Receiving. The detailed error message is: ' + ErrorMessageText);
                                    ModifyMTNA_IF_PurchaseReceiving.Modify();
                                    if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Purchase Receiving Process post', ModifyMTNA_IF_PurchaseReceiving.Plant, Format(ModifyMTNA_IF_PurchaseReceiving."Entry No."),
                                        ModifyMTNA_IF_PurchaseReceiving."Process start datetime", ErrorMessageText) then begin
                                    end;
                                    ErrorRecCount += 1;
                                until ModifyMTNA_IF_PurchaseReceiving.Next() = 0;
                            end;
                        end;

                    end;
                end;
            until RecMTNA_IF_PurchaseReceiving.Next() = 0
        end;

    end;

    [TryFunction]
    local procedure UpdatePurchaseHeader(RecMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving"; var RecPOHeaderLine: Record "Purchase Header"; var RecPOLines: Record "Purchase Line"; var TempPOHeader: Record "Purchase Header" temporary)
    var
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        LocalMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
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
            RecPOHeaderLine.Modify();
            if RecPOHeaderLine.Status = RecPOHeaderLine.Status::Released then
                ReleasePurchDoc.PerformManualReopen(RecPOHeaderLine);

            TempPOHeader.Reset();
            TempPOHeader.SetRange("Document Type", RecPOHeaderLine."Document Type"::Order);
            TempPOHeader.SetRange("No.", RecMTNA_IF_PurchaseReceiving."Order No.");
            if not TempPOHeader.FindFirst() then begin
                TempPOHeader.Init();
                TempPOHeader.TransferFields(RecPOHeaderLine);
                TempPOHeader.Invoice := false;
                TempPOHeader.Insert();

                RecPOLines.Reset();
                RecPOLines.SetRange("Document Type", RecPOHeaderLine."Document Type"::Order);
                RecPOLines.SetRange("Document No.", RecMTNA_IF_PurchaseReceiving."Order No.");
                RecPOLines.ModifyAll("Qty. to Receive", 0);
            end;
        end;

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
                //RecReservationEntry.SetRange("Transferred from Entry No.", 0);
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


    local procedure "Code"(var PurchaseHeader: Record "Purchase Header"): Boolean
    /*var
        PurchSetup: Record "Purchases & Payables Setup";
        PurchPostViaJobQueue: Codeunit "Purchase Post via Job Queue";
        HideDialog: Boolean;
        IsHandled: Boolean;
        DefaultOption: Integer;
        */
    begin
        /*
                DefaultOption := 1;

                PurchSetup.Get();
                if PurchSetup."Post with Job Queue" then
                    PurchPostViaJobQueue.EnqueuePurchDoc(PurchaseHeader)
                else begin*/
        if CODEUNIT.Run(CODEUNIT::"Purch.-Post", PurchaseHeader) then begin
            exit(true);
        end;

        exit(false);
        //end;

    end;

    [TryFunction]
    local procedure PurchaseReceivingErrorMessage(var RecMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving"; ErrorMessageText: Text)
    var
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
    begin
        RecMTNA_IF_PurchaseReceiving.Status := RecMTNA_IF_PurchaseReceiving.Status::Error;
        RecMTNA_IF_PurchaseReceiving.SetErrormessage('Error occurred when updating Purchase Receiving. The detailed error message is: ' + ErrorMessageText);
        RecMTNA_IF_PurchaseReceiving.Modify();
        if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Purchase Receiving Process update', RecMTNA_IF_PurchaseReceiving.Plant, Format(RecMTNA_IF_PurchaseReceiving."Entry No."),
            RecMTNA_IF_PurchaseReceiving."Process start datetime", ErrorMessageText) then begin
        end;
    end;


}

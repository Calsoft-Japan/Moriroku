codeunit 50018 MTNAIFPurchaseReceivingProcArc
{
    //CS 2025/10/15 Channing.Zhou FDD305 CodeUnit for MTNA IF Purchase Receiving Process Archive

    trigger OnRun()
    var
        ErrorRecCount: Integer;
    begin
        if ProcArcAllData(ErrorRecCount) then begin
        end;
    end;

    [TryFunction]
    procedure ProcArcAllData(var ErrorRecCount: Integer)
    var
        RecMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
    begin
        RecMTNA_IF_PurchaseReceiving.Reset();
        RecMTNA_IF_PurchaseReceiving.SetRange(Status, RecMTNA_IF_PurchaseReceiving.Status::Completed);
        /* Will add logic to check if the records need to process archive delay*/
        /**/
        if RecMTNA_IF_PurchaseReceiving.FindFirst() then begin
            ProcArcPurchaseReceivingData(RecMTNA_IF_PurchaseReceiving, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcPurchaseReceivingData(var RecMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving"; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_PurchaseReceivingArchive: Record "MTNA_IF_PurchaseReceivingArc";
    begin
        ErrorRecCount := 0;
        if RecMTNA_IF_PurchaseReceiving.FindFirst() then begin
            repeat
                RecMTNA_IF_PurchaseReceivingArchive.Init();
                RecMTNA_IF_PurchaseReceivingArchive.TransferFields(RecMTNA_IF_PurchaseReceiving);
                RecMTNA_IF_PurchaseReceivingArchive.Insert();
            until RecMTNA_IF_PurchaseReceiving.Next() = 0;
            RecMTNA_IF_PurchaseReceiving.DeleteAll();
        end;
    end;
}
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
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        HoursNoArc: Integer;
    begin
        RecMTNA_IF_PurchaseReceiving.Reset();
        RecMTNA_IF_PurchaseReceiving.SetRange(Status, RecMTNA_IF_PurchaseReceiving.Status::Completed);
        if RecMTNA_IF_PurchaseReceiving.FindFirst() then begin
            HoursNoArc := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Purchase receiving");
            if RecMTNAIFConfiguration.FindFirst() then begin
                HoursNoArc := RecMTNAIFConfiguration."Hours no to acrhive";
            end;
            ProcArcPurchaseReceivingData(RecMTNA_IF_PurchaseReceiving, HoursNoArc, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcPurchaseReceivingData(var RecMTNA_IF_PurchaseReceiving: Record "MTNA_IF_PurchaseReceiving"; HoursNoArc: Integer; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_PurchaseReceivingArchive: Record "MTNA_IF_PurchaseReceivingArc";
        CUCommProc: Codeunit "MTNA_IF_CommonProcArc";
        filteringDT: DateTime;
    begin
        ErrorRecCount := 0;
        if (HoursNoArc > 0) then begin
            filteringDT := CUCommProc.CalcDateTimePlusHours(CurrentDateTime(), -HoursNoArc);
            RecMTNA_IF_PurchaseReceiving.SetFilter("Processed datetime", '<=%1', filteringDT);
        end;
        if RecMTNA_IF_PurchaseReceiving.FindFirst() then begin
            repeat
                RecMTNA_IF_PurchaseReceivingArchive.Init();
                RecMTNA_IF_PurchaseReceivingArchive.TransferFields(RecMTNA_IF_PurchaseReceiving);
                RecMTNA_IF_PurchaseReceivingArchive.Insert(true);
            until RecMTNA_IF_PurchaseReceiving.Next() = 0;
            RecMTNA_IF_PurchaseReceiving.DeleteAll();
        end;
    end;
}
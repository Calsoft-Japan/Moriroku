codeunit 50017 MTNAIFProductionOrderProcArc
{
    //CS 2025/10/13 Channing.Zhou FDD304 CodeUnit for MTNA IF Production Order Process Archive

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
        RecMTNA_IF_ProductionOrder: Record "MTNA_IF_ProductionOrder";
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        HoursNoArc: Integer;
    begin
        RecMTNA_IF_ProductionOrder.Reset();
        RecMTNA_IF_ProductionOrder.SetRange(Status, RecMTNA_IF_ProductionOrder.Status::Completed);
        if RecMTNA_IF_ProductionOrder.FindFirst() then begin
            HoursNoArc := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Production order");
            if RecMTNAIFConfiguration.FindFirst() then begin
                HoursNoArc := RecMTNAIFConfiguration."Hours not to archive";
            end;
            ProcArcProductionOrderData(RecMTNA_IF_ProductionOrder, HoursNoArc, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcProductionOrderData(var RecMTNA_IF_ProductionOrder: Record "MTNA_IF_ProductionOrder"; HoursNoArc: Integer; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_ProductionOrderArchive: Record "MTNA_IF_ProductionOrderArchive";
        CUCommProc: Codeunit "MTNA_IF_CommonProcArc";
        filteringDT: DateTime;
    begin
        ErrorRecCount := 0;
        if (HoursNoArc > 0) then begin
            filteringDT := CUCommProc.CalcDateTimePlusHours(CurrentDateTime(), -HoursNoArc);
            RecMTNA_IF_ProductionOrder.SetFilter("Processed datetime", '<=%1', filteringDT);
        end;
        if RecMTNA_IF_ProductionOrder.FindFirst() then begin
            repeat
                RecMTNA_IF_ProductionOrderArchive.Init();
                RecMTNA_IF_ProductionOrderArchive.TransferFields(RecMTNA_IF_ProductionOrder);
                RecMTNA_IF_ProductionOrderArchive.Insert(true);
            until RecMTNA_IF_ProductionOrder.Next() = 0;
            RecMTNA_IF_ProductionOrder.DeleteAll();
        end;
    end;
}
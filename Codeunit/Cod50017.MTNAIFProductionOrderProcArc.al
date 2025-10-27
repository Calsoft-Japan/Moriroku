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
    begin
        RecMTNA_IF_ProductionOrder.Reset();
        RecMTNA_IF_ProductionOrder.SetRange(Status, RecMTNA_IF_ProductionOrder.Status::Completed);
        /* Will add logic to check if the records need to process archive delay*/
        /**/
        if RecMTNA_IF_ProductionOrder.FindFirst() then begin
            ProcArcProductionOrderData(RecMTNA_IF_ProductionOrder, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcProductionOrderData(var RecMTNA_IF_ProductionOrder: Record "MTNA_IF_ProductionOrder"; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_ProductionOrderArchive: Record "MTNA_IF_ProductionOrderArchive";
    begin
        ErrorRecCount := 0;
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
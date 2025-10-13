codeunit 50014 MTNA_IF_CommonProcArc
{
    //CS 2025/10/10 Channing.Zhou FDD300 CodeUnit for MTNA IF Common Process Archive
    var
        CuEmailMessage: codeunit "Email Message";
        CuEmail: codeunit Email;

    trigger OnRun()
    begin
        if ProcArcAllData() then begin
        end;
    end;

    [TryFunction]
    procedure ProcArcAllData()
    var
        CuMTNAIFOutputJournalProcArc: Codeunit "MTNAIFOutputJournalProcArc";
        //CuMTNAIFPurchaseOrderProcess: Codeunit MTNAIFPurchaseOrderProcess;
        //CuMTNAIFProductionOrderProcess: Codeunit MTNAIFProductionOrderProcess;
        //CUMTNAIFPurchaseReceivingProcess: Codeunit MTNAIFPurchaseReceivingProcess;
        ErrorRecCount: Integer;
    begin
        if not CuMTNAIFOutputJournalProcArc.ProcArcAllData(ErrorRecCount) then begin
        end;

        /*if not CuMTNAIFPurchaseOrderProcess.ProcessAllData(ErrorRecCount) then begin
        end;

        if not CuMTNAIFProductionOrderProcess.ProcessAllData(ErrorRecCount) then begin
        end;

        if not CUMTNAIFPurchaseReceivingProcess.ProcessAllData(ErrorRecCount) then begin
        end;*/
    end;
}

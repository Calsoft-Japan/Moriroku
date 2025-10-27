codeunit 50019 MTNAIFStandardCostProcArc
{
    //CS 2025/10/16 Channing.Zhou FDD305 CodeUnit for MTNA IF Standard Cost Process Archive

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
        RecMTNA_IF_StandardCost: Record "MTNA_IF_StandardCost";
    begin
        RecMTNA_IF_StandardCost.Reset();
        RecMTNA_IF_StandardCost.SetRange(Status, RecMTNA_IF_StandardCost.Status::Completed);
        /* Will add logic to check if the records need to process archive delay*/
        /**/
        if RecMTNA_IF_StandardCost.FindFirst() then begin
            ProcArcStandardCostData(RecMTNA_IF_StandardCost, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcStandardCostData(var RecMTNA_IF_StandardCost: Record "MTNA_IF_StandardCost"; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_StandardCostArchive: Record "MTNA_IF_StandardCostArchive";
    begin
        ErrorRecCount := 0;
        if RecMTNA_IF_StandardCost.FindFirst() then begin
            repeat
                RecMTNA_IF_StandardCostArchive.Init();
                RecMTNA_IF_StandardCostArchive.TransferFields(RecMTNA_IF_StandardCost);
                RecMTNA_IF_StandardCostArchive.Insert(true);
            until RecMTNA_IF_StandardCost.Next() = 0;
            RecMTNA_IF_StandardCost.DeleteAll();
        end;
    end;
}

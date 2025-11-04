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
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        HoursNoArc: Integer;
    begin
        RecMTNA_IF_StandardCost.Reset();
        RecMTNA_IF_StandardCost.SetRange(Status, RecMTNA_IF_StandardCost.Status::Completed);
        if RecMTNA_IF_StandardCost.FindFirst() then begin
            HoursNoArc := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Standard cost");
            if RecMTNAIFConfiguration.FindFirst() then begin
                HoursNoArc := RecMTNAIFConfiguration."Hours no to acrhive";
            end;
            ProcArcStandardCostData(RecMTNA_IF_StandardCost, HoursNoArc, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcStandardCostData(var RecMTNA_IF_StandardCost: Record "MTNA_IF_StandardCost"; HoursNoArc: Integer; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_StandardCostArchive: Record "MTNA_IF_StandardCostArchive";
        CUCommProc: Codeunit "MTNA_IF_CommonProcArc";
        filteringDT: DateTime;
    begin
        ErrorRecCount := 0;
        if (HoursNoArc > 0) then begin
            filteringDT := CUCommProc.CalcDateTimePlusHours(CurrentDateTime(), -HoursNoArc);
            RecMTNA_IF_StandardCost.SetFilter("Processed datetime", '<=%1', filteringDT);
        end;
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

codeunit 50020 MTNAIFItemJournalProcArc
{
    //CS 2025/10/17 Channing.Zhou FDD306 CodeUnit for MTNA IF Item Journal Process Archive

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
        RecMTNA_ItemJournal: Record "MTNA_IF_ItemJournal";
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        HoursNoArc: Integer;
    begin
        RecMTNA_ItemJournal.Reset();
        RecMTNA_ItemJournal.SetRange(Status, RecMTNA_ItemJournal.Status::Completed);
        if RecMTNA_ItemJournal.FindFirst() then begin
            HoursNoArc := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Item journal");
            if RecMTNAIFConfiguration.FindFirst() then begin
                HoursNoArc := RecMTNAIFConfiguration."Hours no to acrhive";
            end;
            ProcArcItemJournalData(RecMTNA_ItemJournal, HoursNoArc, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcItemJournalData(var RecMTNA_IF_ItemJournal: Record "MTNA_IF_ItemJournal"; HoursNoArc: Integer; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_ItemJournalrArchive: Record "MTNA_IF_ItemJournalArchive";
        CUCommProc: Codeunit "MTNA_IF_CommonProcArc";
        filteringDT: DateTime;
    begin
        ErrorRecCount := 0;
        if (HoursNoArc > 0) then begin
            filteringDT := CUCommProc.CalcDateTimePlusHours(CurrentDateTime(), -HoursNoArc);
            RecMTNA_IF_ItemJournal.SetFilter("Processed datetime", '>=%1', filteringDT);
        end;
        if RecMTNA_IF_ItemJournal.FindFirst() then begin
            repeat
                RecMTNA_IF_ItemJournalrArchive.Init();
                RecMTNA_IF_ItemJournalrArchive.TransferFields(RecMTNA_IF_ItemJournal);
                RecMTNA_IF_ItemJournalrArchive.Insert(true);
            until RecMTNA_IF_ItemJournal.Next() = 0;
            RecMTNA_IF_ItemJournal.DeleteAll();
        end;
    end;
}

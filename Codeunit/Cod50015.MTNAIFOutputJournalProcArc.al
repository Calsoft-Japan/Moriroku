codeunit 50015 MTNAIFOutputJournalProcArc
{
    //CS 2025/10/10 Channing.Zhou FDD301 CodeUnit for MTNA IF Output Journal Process Archive

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
        RecMTNA_IF_OutputJournal: Record "MTNA_IF_OutputJournal";
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        HoursNoArc: Integer;
    begin
        RecMTNA_IF_OutputJournal.Reset();
        RecMTNA_IF_OutputJournal.SetRange(Status, RecMTNA_IF_OutputJournal.Status::Completed);
        if RecMTNA_IF_OutputJournal.FindFirst() then begin
            HoursNoArc := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Output journal");
            if RecMTNAIFConfiguration.FindFirst() then begin
                HoursNoArc := RecMTNAIFConfiguration."Hours not to archive";
            end;
            ProcArcOutputJournalData(RecMTNA_IF_OutputJournal, HoursNoArc, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcOutputJournalData(var RecMTNA_IF_OutputJournal: Record "MTNA_IF_OutputJournal"; HoursNoArc: Integer; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_OutputJournalArchive: Record "MTNA_IF_OutputJournalArchive";
        CUCommProc: Codeunit "MTNA_IF_CommonProcArc";
        filteringDT: DateTime;
    begin
        ErrorRecCount := 0;
        if (HoursNoArc > 0) then begin
            filteringDT := CUCommProc.CalcDateTimePlusHours(CurrentDateTime(), -HoursNoArc);
            RecMTNA_IF_OutputJournal.SetFilter("Processed datetime", '<=%1', filteringDT);
        end;
        if RecMTNA_IF_OutputJournal.FindFirst() then begin
            repeat
                RecMTNA_IF_OutputJournalArchive.Init();
                RecMTNA_IF_OutputJournalArchive.TransferFields(RecMTNA_IF_OutputJournal);
                RecMTNA_IF_OutputJournalArchive.Insert(true);
            until RecMTNA_IF_OutputJournal.Next() = 0;
            RecMTNA_IF_OutputJournal.DeleteAll();
        end;
    end;
}

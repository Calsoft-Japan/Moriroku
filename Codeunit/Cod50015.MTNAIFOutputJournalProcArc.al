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
    begin
        RecMTNA_IF_OutputJournal.Reset();
        RecMTNA_IF_OutputJournal.SetRange(Status, RecMTNA_IF_OutputJournal.Status::Completed);
        /* Will add logic to check if the records need to process archive delay*/
        /**/
        if RecMTNA_IF_OutputJournal.FindFirst() then begin
            ProcArcOutputJournalData(RecMTNA_IF_OutputJournal, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcOutputJournalData(var RecMTNA_IF_OutputJournal: Record "MTNA_IF_OutputJournal"; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_OutputJournalArchive: Record "MTNA_IF_OutputJournalArchive";
    begin
        ErrorRecCount := 0;
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

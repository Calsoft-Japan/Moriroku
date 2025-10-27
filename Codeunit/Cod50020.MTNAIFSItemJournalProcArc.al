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
    begin
        RecMTNA_ItemJournal.Reset();
        RecMTNA_ItemJournal.SetRange(Status, RecMTNA_ItemJournal.Status::Completed);
        /* Will add logic to check if the records need to process archive delay*/
        /**/
        if RecMTNA_ItemJournal.FindFirst() then begin
            ProcArcItemJournalData(RecMTNA_ItemJournal, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcItemJournalData(var RecMTNA_IF_ItemJournal: Record "MTNA_IF_ItemJournal"; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_ItemJournalrArchive: Record "MTNA_IF_ItemJournalArchive";
    begin
        ErrorRecCount := 0;
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

codeunit 50021 MTNAIFItemReclasJournalProcArc
{
    //CS 2025/10/20 Channing.Zhou FDD307 CodeUnit for MTNA IF Item Reclass Journal Process Archive

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
        RecMTNA_IF_ItemReclassJournal: Record "MTNA_IF_ItemReclassJournal";
    begin
        RecMTNA_IF_ItemReclassJournal.Reset();
        RecMTNA_IF_ItemReclassJournal.SetRange(Status, RecMTNA_IF_ItemReclassJournal.Status::Completed);
        /* Will add logic to check if the records need to process archive delay*/
        /**/
        if RecMTNA_IF_ItemReclassJournal.FindFirst() then begin
            ProcArcItemReclassJournalData(RecMTNA_IF_ItemReclassJournal, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcItemReclassJournalData(var RecMTNA_IF_ItemReclassJournal: Record "MTNA_IF_ItemReclassJournal"; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_ItemReclassJournalArchive: Record "MTNA_IF_ItemReclassJournalArc";
    begin
        ErrorRecCount := 0;
        if RecMTNA_IF_ItemReclassJournal.FindFirst() then begin
            repeat
                RecMTNA_IF_ItemReclassJournalArchive.Init();
                RecMTNA_IF_ItemReclassJournalArchive.TransferFields(RecMTNA_IF_ItemReclassJournal);
                RecMTNA_IF_ItemReclassJournalArchive.Insert();
            until RecMTNA_IF_ItemReclassJournal.Next() = 0;
            RecMTNA_IF_ItemReclassJournal.DeleteAll();
        end;
    end;
}

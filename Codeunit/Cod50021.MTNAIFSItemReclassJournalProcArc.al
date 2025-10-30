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
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        HoursNoArc: Integer;
    begin
        RecMTNA_IF_ItemReclassJournal.Reset();
        RecMTNA_IF_ItemReclassJournal.SetRange(Status, RecMTNA_IF_ItemReclassJournal.Status::Completed);
        if RecMTNA_IF_ItemReclassJournal.FindFirst() then begin
            HoursNoArc := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Item reclass journal");
            if RecMTNAIFConfiguration.FindFirst() then begin
                HoursNoArc := RecMTNAIFConfiguration."Hours no to acrhive";
            end;
            ProcArcItemReclassJournalData(RecMTNA_IF_ItemReclassJournal, HoursNoArc, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcItemReclassJournalData(var RecMTNA_IF_ItemReclassJournal: Record "MTNA_IF_ItemReclassJournal"; HoursNoArc: Integer; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_ItemReclassJournalArchive: Record "MTNA_IF_ItemReclassJournalArc";
        CUCommProc: Codeunit "MTNA_IF_CommonProcArc";
        filteringDT: DateTime;
    begin
        ErrorRecCount := 0;
        if (HoursNoArc > 0) then begin
            filteringDT := CUCommProc.CalcDateTimePlusHours(CurrentDateTime(), -HoursNoArc);
            RecMTNA_IF_ItemReclassJournal.SetFilter("Processed datetime", '>=%1', filteringDT);
        end;
        if RecMTNA_IF_ItemReclassJournal.FindFirst() then begin
            repeat
                RecMTNA_IF_ItemReclassJournalArchive.Init();
                RecMTNA_IF_ItemReclassJournalArchive.TransferFields(RecMTNA_IF_ItemReclassJournal);
                RecMTNA_IF_ItemReclassJournalArchive.Insert(true);
            until RecMTNA_IF_ItemReclassJournal.Next() = 0;
            RecMTNA_IF_ItemReclassJournal.DeleteAll();
        end;
    end;
}

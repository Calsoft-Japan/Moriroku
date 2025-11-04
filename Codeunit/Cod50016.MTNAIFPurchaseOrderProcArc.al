codeunit 50016 MTNAIFPurchaseOrderProcArc
{
    //CS 2025/10/11 Channing.Zhou FDD302 CodeUnit for MTNA IF Purchase Order Process Archive
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
        RecMTNA_IF_POHeader: Record MTNA_IF_POHeaders;
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        HoursNoArc: Integer;
    begin
        RecMTNA_IF_POHeader.Reset();
        RecMTNA_IF_POHeader.SetRange(Status, RecMTNA_IF_POHeader.Status::Completed);
        if RecMTNA_IF_POHeader.FindFirst() then begin
            HoursNoArc := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Purchase order");
            if RecMTNAIFConfiguration.FindFirst() then begin
                HoursNoArc := RecMTNAIFConfiguration."Hours no to acrhive";
            end;
            ProcArcPurchaseOrderData(RecMTNA_IF_POHeader, HoursNoArc, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcPurchaseOrderData(var RecMTNA_IF_POHeaders: Record MTNA_IF_POHeaders; HoursNoArc: Integer; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_POLines: Record MTNA_IF_POLines;
        RecMTNA_IF_POHeadersArchive: Record MTNA_IF_POHeadersArchive;
        RecMTNA_IF_POLinesArchive: Record MTNA_IF_POLinesArchive;
        CUCommProc: Codeunit "MTNA_IF_CommonProcArc";
        filteringDT: DateTime;
    begin
        ErrorRecCount := 0;
        if (HoursNoArc > 0) then begin
            filteringDT := CUCommProc.CalcDateTimePlusHours(CurrentDateTime(), -HoursNoArc);
            RecMTNA_IF_POHeaders.SetFilter("Processed datetime", '<=%1', filteringDT);
        end;
        if RecMTNA_IF_POHeaders.FindFirst() then begin
            repeat
                RecMTNA_IF_POHeadersArchive.Init();
                RecMTNA_IF_POHeadersArchive.TransferFields(RecMTNA_IF_POHeaders);
                RecMTNA_IF_POHeadersArchive.Insert(true);
                RecMTNA_IF_POLines.Reset();
                RecMTNA_IF_POLines.SetRange("Header Entry No.", RecMTNA_IF_POHeaders."Entry No.");
                if RecMTNA_IF_POLines.FindFirst() then begin
                    repeat
                        RecMTNA_IF_POLinesArchive.Init();
                        RecMTNA_IF_POLinesArchive.TransferFields(RecMTNA_IF_POLines);
                        RecMTNA_IF_POLinesArchive."Header Archive Entry No." := RecMTNA_IF_POHeadersArchive."Archive Entry No.";
                        RecMTNA_IF_POLinesArchive.Insert(true);
                    until RecMTNA_IF_POLines.Next() = 0;
                    RecMTNA_IF_POLines.DeleteAll();
                end;
            until RecMTNA_IF_POHeaders.Next() = 0;
            RecMTNA_IF_POHeaders.DeleteAll();
        end;
    end;
}

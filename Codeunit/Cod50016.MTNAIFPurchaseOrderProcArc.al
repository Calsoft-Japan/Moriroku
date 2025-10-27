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

    begin
        RecMTNA_IF_POHeader.Reset();
        RecMTNA_IF_POHeader.SetRange(Status, RecMTNA_IF_POHeader.Status::Completed);
        /* Will add logic to check if the records need to process archive delay*/
        /**/
        if RecMTNA_IF_POHeader.FindFirst() then begin
            ProcArcPurchaseOrderData(RecMTNA_IF_POHeader, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcArcPurchaseOrderData(var RecMTNA_IF_POHeader: Record MTNA_IF_POHeaders; var ErrorRecCount: Integer)
    var
        RecMTNA_IF_POLine: Record MTNA_IF_POLines;
        RecMTNA_IF_POHeaderArchive: Record MTNA_IF_POHeadersArchive;
        RecMTNA_IF_POLineArchive: Record MTNA_IF_POLinesArchive;
    begin
        ErrorRecCount := 0;
        if RecMTNA_IF_POHeader.FindFirst() then begin
            repeat
                RecMTNA_IF_POHeaderArchive.Init();
                RecMTNA_IF_POHeaderArchive.TransferFields(RecMTNA_IF_POHeader);
                RecMTNA_IF_POHeaderArchive.Insert(true);

                RecMTNA_IF_POLine.Reset();
                RecMTNA_IF_POLine.SetRange("Header Entry No.", RecMTNA_IF_POHeader."Entry No.");
                if RecMTNA_IF_POLine.FindFirst() then begin
                    repeat
                        RecMTNA_IF_POLineArchive.Init();
                        RecMTNA_IF_POLineArchive.TransferFields(RecMTNA_IF_POLine);
                        RecMTNA_IF_POLineArchive."Header Archive Entry No." := RecMTNA_IF_POHeaderArchive."Archive Entry No.";
                        RecMTNA_IF_POLineArchive.Insert(true);
                    until RecMTNA_IF_POLine.Next() = 0;
                    RecMTNA_IF_POLine.DeleteAll();
                end;
            until RecMTNA_IF_POHeader.Next() = 0;
            RecMTNA_IF_POHeader.DeleteAll();
        end;
    end;
}

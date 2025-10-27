table 50017 MTNA_IF_ItemReclassJournalArc
{
    //CS 2024/10/20 Channing.Zhou FDD309 Table for MTNA IF Item Reclass Journal Archive
    Caption = 'MTNA IF Item Reclass Journal Archive';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; Plant; Enum "MTNA IF Plant")
        {
            Caption = 'Plant';
        }
        field(3; Status; Enum "MTNA IF Status")
        {
            Caption = 'Status';
        }
        field(4; "Journal Batch Name"; Text[10])
        {
            Caption = 'Journal Batch Name';
        }
        field(5; "Posting date"; Date)
        {
            Caption = 'Posting date';
        }
        field(6; "Document No."; Text[20])
        {
            Caption = 'Document No.';
        }
        field(7; "Item No."; Text[20])
        {
            Caption = 'Item No.';
        }
        field(8; "Primary record ID"; Text[35])
        {
            Caption = 'Primary record ID';
        }
        field(9; "Location Code"; Text[10])
        {
            Caption = 'Location Code';
        }
        field(10; "New Location Code"; Text[10])
        {
            Caption = 'New Location Code';
        }
        field(11; "Bin Code"; Text[20])
        {
            Caption = 'Bin Code';
        }
        field(12; "New Bin Code"; Text[20])
        {
            Caption = 'New Bin Code';
        }
        field(13; "Unit of Measure Code"; Text[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(14; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
        }
        field(15; "Lot No."; Text[50])
        {
            Caption = 'Lot No.';
        }
        field(16; "Gen Bus Posting Group"; Text[20])
        {
            Caption = 'Gen Bus Posting Group';
        }
        field(17; "Created datetime"; DateTime)
        {
            Caption = 'Created datetime';
        }
        field(18; "Processed datetime"; DateTime)
        {
            Caption = 'Processed datetime';
        }
        field(19; "Process start datetime"; DateTime)
        {
            Caption = 'Process start datetime';
        }
        field(20; "Error message"; Blob)
        {
            Caption = 'Error message';
        }
        field(21; "Archive Entry No."; Integer)
        {
            Caption = 'Archive Entry No.';
        }
    }
    keys
    {
        key(PK; "Archive Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        RecMTNAIFItemReclassJournalArchive: Record "MTNA_IF_ItemReclassJournalArc";
        LastArchiveEntryNo_: integer;
    begin
        LastArchiveEntryNo_ := 0;
        if RecMTNAIFItemReclassJournalArchive.FindLast() then begin
            LastArchiveEntryNo_ := RecMTNAIFItemReclassJournalArchive."Archive Entry No.";
        end;
        LastArchiveEntryNo_ += 1;
        Rec."Archive Entry No." := LastArchiveEntryNo_;
    end;

    procedure SetErrormessage(NewErrormessage: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Error message");
        "Error message".CreateOutStream(OutStream);
        OutStream.WriteText(NewErrormessage);
    end;

    procedure GetErrormessage() Errormessage: Text
    var
        CuTypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Error message");
        "Error message".CreateInStream(InStream);
        exit(CuTypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, CuTypeHelper.LFSeparator(), FieldName("Error message")));
    end;
}

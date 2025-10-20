table 50016 MTNA_IF_ItemJournalArchive
{
    //CS 2025/10/17 Channing.Zhou FDD307 Table for MTNA IF Item Journal Archive
    Caption = 'MTNA IF Item Journal Archive';

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
        field(5; "Entry Type"; Enum "MTNA IF Item Jour. Entry Type")
        {
            Caption = 'Entry Type';
        }
        field(6; "Posting date"; Date)
        {
            Caption = 'Posting date';
        }
        field(7; "Document No."; Text[20])
        {
            Caption = 'Document No.';
        }
        field(8; "Item No."; Text[20])
        {
            Caption = 'Item No.';
        }
        field(9; "Primary record ID"; Text[35])
        {
            Caption = 'Primary record ID';
        }
        field(10; "Location Code"; Text[10])
        {
            Caption = 'Location Code';
        }
        field(11; "Bin Code"; Text[20])
        {
            Caption = 'Bin Code';
        }
        field(12; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
        }
        field(13; "Unit of Measure Code"; Text[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(14; "Lot No."; Text[50])
        {
            Caption = 'Lot No.';
        }
        field(15; "Gen Bus Posting Group"; Text[20])
        {
            Caption = 'Gen Bus Posting Group';
        }
        field(16; "Created datetime"; DateTime)
        {
            Caption = 'Created datetime';
        }
        field(17; "Processed datetime"; DateTime)
        {
            Caption = 'Processed datetime';
        }
        field(18; "Process start datetime"; DateTime)
        {
            Caption = 'Process start datetime';
        }
        field(19; "Error message"; Blob)
        {
            Caption = 'Error message';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        RecMNTAIFItemJournal: Record "MTNA_IF_ItemJournal";
        LastEntryNo_: integer;
    begin
        LastEntryNo_ := 0;
        if RecMNTAIFItemJournal.FindLast() then begin
            LastEntryNo_ := RecMNTAIFItemJournal."Entry No.";
        end;
        LastEntryNo_ += 1;
        Rec."Entry No." := LastEntryNo_;
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

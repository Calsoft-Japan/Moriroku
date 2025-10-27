table 50015 MTNA_IF_StandardCostArchive
{
    //CS 2025/10/16 Channing.Zhou FDD306 Table for MTNA IF Standard Cost Archive
    Caption = 'MTNA IF Standard Cost Archive';

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
        field(4; "Standard Cost Worksheet Name"; Text[10])
        {
            Caption = 'Standard Cost Worksheet Name';
        }
        field(5; "No."; Text[20])
        {
            Caption = 'Item No.';
        }
        field(6; "New Standard Cost"; Decimal)
        {
            Caption = 'New Standard Cost';
        }
        field(7; "Created datetime"; DateTime)
        {
            Caption = 'Created datetime';
        }
        field(8; "Processed datetime"; DateTime)
        {
            Caption = 'Processed datetime';
        }
        field(9; "Process start datetime"; DateTime)
        {
            Caption = 'Process start datetime';
        }
        field(10; "Error message"; Blob)
        {
            Caption = 'Error message';
        }
        field(11; "Archive Entry No."; Integer)
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
        RecMTNAIFStandardJournalArchive: Record "MTNA_IF_StandardCostArchive";
        LastArchiveEntryNo_: integer;
    begin
        LastArchiveEntryNo_ := 0;
        if RecMTNAIFStandardJournalArchive.FindLast() then begin
            LastArchiveEntryNo_ := RecMTNAIFStandardJournalArchive."Archive Entry No.";
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

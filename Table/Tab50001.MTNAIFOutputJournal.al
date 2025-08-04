table 50001 MTNA_IF_OutputJournal
{
    //CS 2024/8/13 Channing.Zhou FDD301 Table for MTNA IF Output Journal
    Caption = 'MTNA IF Output Journal';

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
        field(6; "Order No."; Text[20])
        {
            Caption = 'Order No.';
        }
        field(7; "Item No."; Text[20])
        {
            Caption = 'Item No.';
        }
        field(8; "Primary record ID"; Text[50])
        {
            Caption = 'Primary record ID';
        }
        field(9; "Operation No."; Text[10])
        {
            Caption = 'Operation No.';
        }
        field(10; "Location Code"; Text[10])
        {
            Caption = 'Location Code';
        }
        field(11; "Bin Code"; Text[20])
        {
            Caption = 'Bin Code';
        }
        field(12; "Machine Center Code"; Text[20])
        {
            Caption = 'Machine Center Code';
        }
        field(13; "Output Quantity"; Decimal)
        {
            Caption = 'Output Quantity';
        }
        field(14; "Work Shift Code"; Text[10])
        {
            Caption = 'Work Shift Code';
        }
        field(15; "Scrap Quantity"; Decimal)
        {
            Caption = 'Scrap Quantity';
        }
        field(16; "Scrap Code"; Text[10])
        {
            Caption = 'Scrap Code';
        }
        field(17; "Setup Time"; Decimal)
        {
            Caption = 'Setup Time';
        }
        field(18; "Created datetime"; DateTime)
        {
            Caption = 'Created datetime';
        }
        field(19; "Processed datetime"; DateTime)
        {
            Caption = 'Processed datetime';
        }
        field(20; "Process start datetime"; DateTime)
        {
            Caption = 'Process start datetime';
        }
        field(21; "Error message"; Blob)
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
        RecMNTAIFOutputJournal: Record "MTNA_IF_OutputJournal";
        LastEntryNo_: integer;
    begin
        LastEntryNo_ := 0;
        if RecMNTAIFOutputJournal.FindLast() then begin
            LastEntryNo_ := RecMNTAIFOutputJournal."Entry No.";
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

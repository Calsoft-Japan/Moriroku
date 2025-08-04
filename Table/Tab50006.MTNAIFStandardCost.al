table 50006 MTNA_IF_StandardCost
{
    //CS 2024/9/5 Channing.Zhou FDD306 Table for MTNA IF Standard Cost
    Caption = 'MTNA IF Standard Cost';

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
        RecMNTAIFStandardCost: Record "MTNA_IF_StandardCost";
        LastEntryNo_: integer;
    begin
        LastEntryNo_ := 0;
        if RecMNTAIFStandardCost.FindLast() then begin
            LastEntryNo_ := RecMNTAIFStandardCost."Entry No.";
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

table 50012 MTNA_IF_POLinesArchive
{
    //CS 2025/10/11 Channing.Zhou FDD302 Table for MTNA IF POLines Archive
    Caption = 'MTNA IF POLines Archive';

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
        field(4; "Header Entry No."; Integer)
        {
            Caption = 'Header Entry No.';
            TableRelation = MTNA_IF_POHeadersArchive."Entry No.";
        }
        field(5; "Order ID"; Text[20])
        {
            Caption = 'Order ID';
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(7; "Type"; Enum "Purchase Line Type")
        {
            Caption = 'Type';
        }
        field(8; "No."; Text[20])
        {
            Caption = 'No.';
        }
        field(9; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(10; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
        }
        field(11; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(12; "Unit of Measure Code"; Text[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(13; "Shortcut Dimension 1 Code"; Text[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(14; "Shortcut Dimension 2 Code"; Text[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
        }
        field(15; "Location Code"; Text[10])
        {
            Caption = 'Location Code';
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
        field(20; "Archive Entry No."; Integer)
        {
            Caption = 'Archive Entry No.';
            //AutoIncrement = true;
        }
        field(21; "Header Archive Entry No."; Integer)
        {
            Caption = 'Header Entry No.';
            TableRelation = MTNA_IF_POHeadersArchive."Archive Entry No.";
        }
    }
    keys
    {
        key(PK; "Archive Entry No.", "Header Archive Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        RecMTNAIFPOLinesArchive: Record "MTNA_IF_POLinesArchive";
        LastEArchiventryNo_: integer;
    begin
        LastEArchiventryNo_ := 0;
        if RecMTNAIFPOLinesArchive.FindLast() then begin
            LastEArchiventryNo_ := RecMTNAIFPOLinesArchive."Archive Entry No.";
        end;
        LastEArchiventryNo_ += 1;
        Rec."Archive Entry No." := LastEArchiventryNo_;
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

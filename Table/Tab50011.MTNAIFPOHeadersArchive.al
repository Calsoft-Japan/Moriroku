table 50011 MTNA_IF_POHeadersArchive
{
    //CS 2025/10/11 Channing.Zhou FDD302 Table for MTNA IF POHeader Archive
    Caption = 'MTNA IF POHeader Archive';

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
        field(4; "Order ID"; Text[20])
        {
            Caption = 'Order ID';
        }
        field(5; "Vendor No."; Text[20])
        {
            Caption = 'Vendor No.';
        }
        field(6; "Your Reference"; Text[35])
        {
            Caption = 'Your Reference';
        }
        field(7; "Location Code"; Text[10])
        {
            Caption = 'Location Code';
        }
        field(8; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(9; "Shipment Method Code"; Text[10])
        {
            Caption = 'Shipment Method Code';
        }
        field(10; "Responsibility Center"; Text[10])
        {
            Caption = 'Responsibility Center';
        }
        field(11; "Requested Receipt Date"; Date)
        {
            Caption = 'Requested Receipt Date';
        }
        field(12; "Currency Code"; Text[10])
        {
            Caption = 'Currency Code';
        }
        field(13; "Shortcut Dimension 1 Code"; Text[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(14; "Shortcut Dimension 2 Code"; Text[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
        }
        field(15; "Created datetime"; DateTime)
        {
            Caption = 'Created datetime';
        }
        field(16; "Processed datetime"; DateTime)
        {
            Caption = 'Processed datetime';
        }
        field(17; "Process start datetime"; DateTime)
        {
            Caption = 'Process start datetime';
        }
        field(18; "Error message"; Blob)
        {
            Caption = 'Error message';
        }
        field(19; "Archive Entry No."; Integer)
        {
            Caption = 'Archive Entry No.';
            //AutoIncrement = true;
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
        RecMTNAIFPOHeadersArchive: Record MTNA_IF_POHeadersArchive;
        LastEArchiventryNo_: integer;
    begin
        LastEArchiventryNo_ := 0;
        if RecMTNAIFPOHeadersArchive.FindLast() then begin
            LastEArchiventryNo_ := RecMTNAIFPOHeadersArchive."Archive Entry No.";
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

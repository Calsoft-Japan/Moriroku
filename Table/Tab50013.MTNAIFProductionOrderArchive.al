table 50013 MTNA_IF_ProductionOrderArchive
{
    //CS 2025/10/13 Channing.Zhou FDD304 Table for MTNA IF Production Order Archive
    Caption = 'MTNA IF Production Order';

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
        field(4; "Order date"; Date)
        {
            Caption = 'Order date';
        }
        field(5; "Item No."; Text[20])
        {
            Caption = 'Item No.';
        }
        field(6; "APS Starting Date"; Date)
        {
            Caption = 'APS Starting Date';
        }
        field(7; "APS Starting Time"; Time)
        {
            Caption = 'APS Starting Time';
        }
        field(8; "APS Ending Date"; Date)
        {
            Caption = 'APS Ending Date';
        }
        field(9; "APS Ending Time"; Time)
        {
            Caption = 'APS Ending Time';
        }
        field(10; "Location Code"; Text[10])
        {
            Caption = 'Location Code';
        }
        field(11; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
        }
        field(12; "Work Center Code"; Text[20])
        {
            Caption = 'Work Center Code';
        }
        field(13; "Production Order No."; Text[20])
        {
            Caption = 'Production Order No.';
        }
        field(14; "Created datetime"; DateTime)
        {
            Caption = 'Created datetime';
        }
        field(15; "Processed datetime"; DateTime)
        {
            Caption = 'Processed datetime';
        }
        field(16; "Process start datetime"; DateTime)
        {
            Caption = 'Process start datetime';
        }
        field(17; "Error message"; Blob)
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

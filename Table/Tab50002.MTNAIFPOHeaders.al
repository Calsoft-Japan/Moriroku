table 50002 MTNA_IF_POHeaders
{
    //CS 2024/9/3 Bobby.Ji FDD302 Table for MTNA IF POHeader
    Caption = 'MTNA IF POHeader';

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
            trigger OnValidate()
            var
                MTNAIFPOLines: Record MTNA_IF_POLines;
            begin
                if Rec."Order ID" <> xRec."Order ID" then begin
                    MTNAIFPOLines.Reset();
                    MTNAIFPOLines.SetRange("Header Entry No.", Rec."Entry No.");
                    MTNAIFPOLines.ModifyAll("Order ID", Rec."Order ID");
                end;
            end;
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
        RecMTNAIFPOHeaders: Record MTNA_IF_POHeaders;
        LastEntryNo_: integer;
    begin
        LastEntryNo_ := 0;
        if RecMTNAIFPOHeaders.FindLast() then begin
            LastEntryNo_ := RecMTNAIFPOHeaders."Entry No.";
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

table 50005 MTNA_IF_PurchaseReceiving
{
    //CS 2024/9/5 Channing.Zhou FDD305 Table for MTNA IF Purchase Receiving
    Caption = 'MTNA IF Purchase Receiving';

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
        field(4; "Order No."; Text[20])
        {
            Caption = 'Order No.';
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(6; "Vendor Shipment No."; Text[35])
        {
            Caption = 'Vendor Shipment No.';
        }
        field(7; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(8; "Qty. to Receive"; Decimal)
        {
            Caption = 'Qty. to Receive';
        }
        field(9; "Location Code"; Text[10])
        {
            Caption = 'Location Code';
        }
        field(10; "Bin Code"; Text[20])
        {
            Caption = 'Bin Code';
        }
        field(11; "Lot Number"; Text[50])
        {
            Caption = 'Lot Number';
        }
        field(12; "Created datetime"; DateTime)
        {
            Caption = 'Created datetime';
        }
        field(13; "Processed datetime"; DateTime)
        {
            Caption = 'Processed datetime';
        }
        field(14; "Process start datetime"; DateTime)
        {
            Caption = 'Process start datetime';
        }
        field(15; "Error message"; Blob)
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
        RecMNTAIFPurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
        LastEntryNo_: integer;
    begin
        LastEntryNo_ := 0;
        if RecMNTAIFPurchaseReceiving.FindLast() then begin
            LastEntryNo_ := RecMNTAIFPurchaseReceiving."Entry No.";
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

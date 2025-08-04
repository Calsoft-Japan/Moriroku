pageextension 50015 "Customer Ledger Entries Ext" extends "Customer Ledger Entries"
{
    layout
    {
        addafter("Salesperson Code")
        {
            field("ASN No."; Rec."ASN No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = true;
            }
        }
    }
}

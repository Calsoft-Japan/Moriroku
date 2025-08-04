pageextension 50016 "Apply Customer Entries Ext" extends "Apply Customer Entries"
{
    layout
    {
        addafter("Currency Code")
        {
            field("ASN No."; Rec."ASN No.")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}

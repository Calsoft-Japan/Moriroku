pageextension 50017 "Posted Sales Invoices Ext" extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Currency Code")
        {
            field("Package Tracking No."; Rec."Package Tracking No.")
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
            }
        }
    }
}

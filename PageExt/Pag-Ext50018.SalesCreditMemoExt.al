pageextension 50018 "Sales Credit Memo Ext" extends "Sales Credit Memo"
{
    layout
    {
        addafter("External Document No.")
        {
            field("Package Tracking No."; Rec."Package Tracking No.")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
            }
        }
    }
}

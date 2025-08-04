pageextension 50019 "Sales Credit Memos List Ext" extends "Sales Credit Memos"
{
    layout
    {
        addafter("External Document No.")
        {
            field("Package Tracking No."; Rec."Package Tracking No.")
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
            }
        }
    }
}

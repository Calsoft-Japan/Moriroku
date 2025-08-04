pageextension 50020 "Posted Sales Credit Memos Ext" extends "Posted Sales Credit Memos"
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

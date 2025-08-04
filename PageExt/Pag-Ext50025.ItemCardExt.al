pageextension 50025 "Item Card Ext" extends "Item Card"
{
    layout
    {
        addafter("Purchasing Code")
        {
            field("Exclude from Plan. Wksh."; Rec."Exclude from Plan. Wksh.")
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
            }
        }
    }
}

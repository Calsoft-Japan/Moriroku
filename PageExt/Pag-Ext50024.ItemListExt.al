pageextension 50024 "Item List Ext" extends "Item List"
{
    layout
    {
        addafter("Item Category Code")
        {
            field("Exclude from Plan. Wksh."; Rec."Exclude from Plan. Wksh.")
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
            }
        }
    }
}

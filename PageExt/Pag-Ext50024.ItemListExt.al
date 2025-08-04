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
            field("Exclude from Std. Cost Roll"; Rec."Exclude from Std. Cost Roll")
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
            }
        }
    }
}

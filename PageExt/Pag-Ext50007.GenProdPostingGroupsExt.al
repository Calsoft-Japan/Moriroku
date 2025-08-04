pageextension 50007 "Gen. Prod. Posting Groups Ext" extends "Gen. Product Posting Groups"
{
    layout
    {
        addafter(Description)
        {
            field("COGS Allocation Account"; Rec."COGS Allocation Account")
            {
                ApplicationArea = Manufacturing;
                Importance = Promoted;
                Editable = true;
            }
            field("SCRAP Allocation Account"; Rec."SCRAP Allocation Account")
            {
                ApplicationArea = Manufacturing;
                Importance = Promoted;
                Editable = true;
            }
            field("ADJUSTMENT Allocation Account"; Rec."ADJUSTMENT Allocation Account")
            {
                ApplicationArea = Manufacturing;
                Importance = Promoted;
                Editable = true;
            }
            field("REVALUE Allocation Account"; Rec."REVALUE Allocation Account")
            {
                ApplicationArea = Manufacturing;
                Importance = Promoted;
                Editable = true;
                //Visible = false;
            }
        }
    }
}

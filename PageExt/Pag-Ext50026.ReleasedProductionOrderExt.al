pageextension 50026 ReleasedProductionOrderExt extends "Released Production Order"
{
    //CS 2024/9/10 Page Ext for Production Order List by Bobby
    layout
    {
        addafter("Due Date")
        {
            field("Due Time"; Rec."Due Time")
            {
                Editable = false;
                ApplicationArea = all;
            }
        }
    }
}

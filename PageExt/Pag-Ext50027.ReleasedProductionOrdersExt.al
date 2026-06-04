pageextension 50027 ReleasedProductionOrdersExt extends "Released Production Orders"
{
    //CS 2026/6/3 Page Ext for Released Production Orders by Channing.Zhou
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

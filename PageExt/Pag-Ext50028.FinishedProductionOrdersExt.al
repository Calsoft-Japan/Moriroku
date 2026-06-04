pageextension 50028 FinishedProductionOrdersExt extends "Finished Production Orders"
{
    //CS 2026/6/3 Page Ext for Finished Production Orders by Channing.Zhou
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

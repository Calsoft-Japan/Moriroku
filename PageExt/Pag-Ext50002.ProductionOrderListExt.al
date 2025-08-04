pageextension 50002 ProductionOrderListExt extends "Production Order List"
{
    //CS 2024/9/10 Page Ext for Production Order List by Bobby
    layout
    {
        addafter("Search Description")
        {
            field("APS Starting Date"; Rec."APS Starting Date")
            {
                Editable = false;
                ApplicationArea = all;
            }
            field("APS Starting Time"; Rec."APS Starting Time")
            {
                Editable = false;
                ApplicationArea = all;
            }
            field("APS Ending Date"; Rec."APS Ending Date")
            {
                Editable = false;
                ApplicationArea = all;
            }
            field("APS Ending Time"; Rec."APS Ending Time")
            {
                Editable = false;
                ApplicationArea = all;
            }
        }
    }
}

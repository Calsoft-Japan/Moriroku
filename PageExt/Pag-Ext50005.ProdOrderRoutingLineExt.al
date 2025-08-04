pageextension 50005 ProdOrderRoutingLineExt extends "Prod. Order Routing"
{
    //CS 2024/9/10 Page Ext for Prod. Order Routing Line by Bobby
    layout
    {
        addafter("Move Time")
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

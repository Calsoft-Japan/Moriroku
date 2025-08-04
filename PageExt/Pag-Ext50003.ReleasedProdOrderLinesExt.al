pageextension 50003 "Released Prod. Order Lines Ext" extends "Released Prod. Order Lines"
{
    //CS 2024/9/10 Page Ext for Released Prod. Order Line by Bobby
    layout
    {
        addafter("Ending Date")
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

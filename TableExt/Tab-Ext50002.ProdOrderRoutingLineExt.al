tableextension 50002 "Prod. Order Routing Line Ext" extends "Prod. Order Routing Line"
{
    fields
    {
        field(50000; "APS Starting Date"; Date)
        {
            Caption = 'APS Starting Date';
            DataClassification = ToBeClassified;
        }
        field(50001; "APS Starting Time"; Time)
        {
            Caption = 'APS Starting Time';
            DataClassification = ToBeClassified;
        }
        field(50002; "APS Ending Date"; Date)
        {
            Caption = 'APS Ending Date';
            DataClassification = ToBeClassified;
        }
        field(50003; "APS Ending Time"; Time)
        {
            Caption = 'APS Ending Time';
            DataClassification = ToBeClassified;
        }
    }
}

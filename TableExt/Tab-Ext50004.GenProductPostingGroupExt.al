tableextension 50004 "Gen. Product Posting Group Ext" extends "Gen. Product Posting Group"
{
    fields
    {
        field(50000; "COGS Allocation Account"; Code[20])
        {
            Caption = 'COGS Allocation Account';
            TableRelation = "G/L Account"."No.";
        }
        field(50001; "SCRAP Allocation Account"; Code[20])
        {
            Caption = 'SCRAP Allocation Account';
            TableRelation = "G/L Account"."No.";
        }
        field(50002; "ADJUSTMENT Allocation Account"; Code[20])
        {
            Caption = 'ADJUSTMENT Allocation Account';
            TableRelation = "G/L Account"."No.";
        }
        field(50003; "REVALUE Allocation Account"; Code[20])
        {
            Caption = 'REVALUE Allocation Account';
            TableRelation = "G/L Account"."No.";
        }
    }
}

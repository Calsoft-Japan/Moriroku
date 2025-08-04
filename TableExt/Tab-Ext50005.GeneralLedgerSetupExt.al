tableextension 50005 "General Ledger Setup Ext" extends "General Ledger Setup"
{
    fields
    {
        field(50000; "COGS Alloc. Rounding Account"; Code[20])
        {
            Caption = 'COGS Alloc. Rounding Account';
            TableRelation = "G/L Account"."No.";
        }
        field(50001; "COGS Alloc. Offset Account"; Code[20])
        {
            Caption = 'COGS Alloc. Offset Account';
            TableRelation = "G/L Account"."No.";
        }
        field(50002; "Adjust Alloc. Offset Account"; Code[20])
        {
            Caption = 'Adjustment Alloc. Offset Account';
            TableRelation = "G/L Account"."No.";
        }
        field(50003; "Scrap Alloc. Offset Account"; Code[20])
        {
            Caption = 'Scrap Alloc. Offset Account';
            TableRelation = "G/L Account"."No.";
        }
        field(50004; "Revalue Alloc. Offset Account"; Code[20])
        {
            Caption = 'Revaluation Alloc. Offset Account';
            TableRelation = "G/L Account"."No.";
        }
    }
}

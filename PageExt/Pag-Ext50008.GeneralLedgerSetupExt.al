pageextension 50008 "General Ledger Setup Ext" extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("COGS Alloc. Rounding Account"; Rec."COGS Alloc. Rounding Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("COGS Alloc. Offset Account"; Rec."COGS Alloc. Offset Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Adjust Alloc. Offset Account"; Rec."Adjust Alloc. Offset Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Scrap Alloc. Offset Account"; Rec."Scrap Alloc. Offset Account")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Revalue Alloc. Offset Account"; Rec."Revalue Alloc. Offset Account")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
}

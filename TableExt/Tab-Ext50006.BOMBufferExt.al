tableextension 50006 "BOM Buffer Ext" extends "BOM Buffer"
{
    fields
    {
        field(50000; "Parent Item No."; Code[20])
        { }
        /*
        field(50001; "Entry Type"; Option)
        {
            OptionMembers = Sales,Scrap,Adjustment;
        }
        field(50002; "Total Cost per Item"; Decimal)
        {
            ToolTip = 'Total cost per 1 item';
        }
        field(50003; "Rate"; Decimal)
        {
            ToolTip = 'Cost ratio';
        }
        field(50004; "Allocation Amount"; Decimal)
        {
            ToolTip = 'Total Cost amount during the specified period in Value Entry';
        }
        field(50005; "Total Value Entry Cost"; Decimal)
        { }
        field(50006; "COGS Allocation Account"; Code[20])
        { }
        field(50007; "G/L Account Cost"; Decimal)
        { }*/
    }
    trigger OnBeforeInsert()
    var
        BOMCostSharesCal: Record "BOM Cost shares Calculated";
    begin
        /* BOMCostSharesCal.Reset();
        BOMCostSharesCal.Init();
        BOMCostSharesCal.TransferFields(Rec);
        //BOMCostSharesCal.Copy(Rec);
        BOMCostSharesCal.Insert(true); */
    end;
}

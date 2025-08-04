pageextension 50010 "Finance Manager Role CenterExt" extends "Finance Manager Role Center"
{
    actions
    {
        addafter("Post Inventory Cost to G/L")
        {
            action("BOM Cost shares Calculated")
            {
                ApplicationArea = All;
                Caption = 'BOM Cost shares Calculated';
                RunObject = page "BOM Cost shares Calculated";
                Tooltip = 'Run the BOM Cost shares Calculated page.';
            }
        }
    }
}

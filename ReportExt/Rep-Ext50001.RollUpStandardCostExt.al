reportextension 50001 "Roll Up Standard Cost Ext." extends "Roll Up Standard Cost"
{
    dataset
    {
        modify(Item)
        {
            RequestFilterFields = "No.", "Costing Method", "Exclude from Std. Cost Roll";
        }
    }
    requestpage
    {
        trigger OnOpenPage()
        begin
            Item.SetRange("Exclude from Std. Cost Roll", false);
        end;
    }
}

reportextension 50000 "Calculate Plan - Plan Wksh Ext" extends "Calculate Plan - Plan. Wksh."
{
    dataset
    {
        modify(Item)
        {
            RequestFilterFields = "No.", Description, "Location Filter", "Exclude from Plan. Wksh.";
        }
    }
    requestpage
    {
        trigger OnOpenPage()
        begin
            Item.SetRange("Exclude from Plan. Wksh.", false);
        end;
    }
}

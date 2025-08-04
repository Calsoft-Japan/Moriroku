pageextension 50001 "Standard Cost Worksheet Ext" extends "Standard Cost Worksheet"
{
    actions
    {
        modify("Roll Up Standard Cost")
        {
            Visible = false;
        }

        addafter("Roll Up Standard Cost")
        {
            action("Roll Up Standard Cost Ext")
            {
                ApplicationArea = Assembly;
                Caption = 'Roll Up Standard Cost';
                Ellipsis = true;
                Image = RollUpCosts;
                ToolTip = 'Roll up the standard costs of assembled and manufactured items, for example, with changes in the standard cost of components and changes in the standard cost of production capacity and assembly resources. When you run the function, all changes to the standard costs in the worksheet are introduced in the associated production or assembly BOMs, and the costs are applied at each BOM level.';

                trigger OnAction()
                var
                    Item: Record Item;
                    RollUpStdCost_FDD107: Report "Roll Up Standard Cost FDD107";
                    StdCostWkshName: Record "Standard Cost Worksheet Name";
                    CurrWkshName: Code[10];
                    DefaultNameTxt: Label 'Default';
                begin
                    if Rec."Standard Cost Worksheet Name" <> '' then // called from batch
                        CurrWkshName := Rec."Standard Cost Worksheet Name";

                    if not StdCostWkshName.Get(CurrWkshName) then
                        if not StdCostWkshName.FindFirst() then begin
                            StdCostWkshName.Name := DefaultNameTxt;
                            StdCostWkshName.Description := DefaultNameTxt;
                            StdCostWkshName.Insert();
                        end;
                    CurrWkshName := StdCostWkshName.Name;

                    Clear(RollUpStdCost_FDD107);
                    Item.SetRange("Costing Method", Item."Costing Method"::Standard);
                    Item.SetFilter("Replenishment System", '%1|%2', Item."Replenishment System"::"Prod. Order", Item."Replenishment System"::Assembly);
                    Item.SetAscending("No.", true);

                    RollUpStdCost_FDD107.SetTableView(Item);
                    RollUpStdCost_FDD107.SetStdCostWksh(CurrWkshName);
                    RollUpStdCost_FDD107.RunModal();
                end;
            }
        }
    }
}

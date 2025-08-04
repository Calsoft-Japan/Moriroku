page 50017 "BOM Cost shares Calculated"
{
    ApplicationArea = All;
    Caption = 'BOM Cost shares Calculated';
    PageType = List;
    SourceTable = "BOM Cost shares Calculated";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                IndentationColumn = Rec.Indentation;
                ShowAsTree = true;
                field("Parent Item No."; Rec."Parent Item No.")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies the item''s Parent Item No. in the BOM structure. Lower-level items are indented under their parents.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies the item''s position in the BOM structure. Lower-level items are indented under their parents.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = IsParentExpr;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = IsParentExpr;
                    ToolTip = 'Specifies the item''s description.';
                }
                field(HasWarning; HasWarning)
                {
                    Visible = false;
                    ApplicationArea = Assembly;
                    BlankZero = true;
                    Caption = 'Warning';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = HasWarning;
                    ToolTip = 'Specifies if the field can be chosen to open the BOM Warning Log window to see a description of the issue.';

                    trigger OnDrillDown()
                    begin
                        if HasWarning then
                            ShowWarnings();
                    end;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant code that you entered in the Variant Filter field in the Item Availability by BOM Level window.';
                    Visible = false;
                }
                field("Qty. per Parent"; Rec."Qty. per Parent")
                {
                    ApplicationArea = Assembly;
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies how many units of the component are required to assemble or produce one unit of the parent.';
                }
                field("Qty. per Top Item"; Rec."Qty. per Top Item")
                {
                    ApplicationArea = Assembly;
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                    ToolTip = 'Specifies how many units of the component are required to assemble or produce one unit of the top item.';
                }
                field("Qty. per BOM Line"; Rec."Qty. per BOM Line")
                {
                    ApplicationArea = Assembly;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies how many units of the component are required to assemble or produce one unit of the item on the BOM line.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("BOM Unit of Measure Code"; Rec."BOM Unit of Measure Code")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    ToolTip = 'Specifies the unit of measure of the BOM item. ';
                }
                field("Replenishment System"; Rec."Replenishment System")
                {
                    ApplicationArea = Assembly;
                    Editable = false;
                    ToolTip = 'Specifies the item''s replenishment system.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Assembly;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                    Visible = false;
                }
                field("Scrap %"; Rec."Scrap %")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the percentage of the item that you expect to be scrapped in the production process.';
                    Visible = false;
                }
                field("Scrap Qty. per Parent"; Rec."Scrap Qty. per Parent")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies how many units of the item are scrapped to output the top item quantity.';
                    Visible = false;
                }
                field("Scrap Qty. per Top Item"; Rec."Scrap Qty. per Top Item")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies how many units of the item are scrapped to output the parent item quantity.';
                    Visible = false;
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the percentage of the item''s last purchase cost that includes indirect costs, such as freight that is associated with the purchase of the item.';
                    Visible = false;
                }
                field("Overhead Rate"; Rec."Overhead Rate")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the item''s overhead rate.';
                    Visible = false;
                }
                field("Lot Size"; Rec."Lot Size")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item''s lot size. The value is copied from the Lot Size field on the item card.';
                    Visible = false;
                }
                field("Production BOM No."; Rec."Production BOM No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the production BOM that the item represents.';
                    Visible = false;
                }
                field("Routing No."; Rec."Routing No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the item''s production order routing.';
                    Visible = false;
                }
                field("Resource Usage Type"; Rec."Resource Usage Type")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies how the cost of the resource on the assembly BOM is allocated during assembly.';
                    Visible = false;
                }
                field("Rolled-up Material Cost"; Rec."Rolled-up Material Cost")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies the material cost of all items at all levels of the parent item''s BOM, added to the material cost of the item itself.';
                }
                field("Rolled-up Capacity Cost"; Rec."Rolled-up Capacity Cost")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies the capacity costs related to the item''s parent item and other items in the parent item''s BOM.';
                }
                field("Rolled-up Subcontracted Cost"; Rec."Rolled-up Subcontracted Cost")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the single-level cost of outsourcing operations to a subcontractor.';
                    Visible = false;
                }
                field("Rolled-up Mfg. Ovhd Cost"; Rec."Rolled-up Mfg. Ovhd Cost")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the item''s overhead capacity cost rolled up from underlying item levels.';
                    Visible = false;
                }
                field("Rolled-up Capacity Ovhd. Cost"; Rec."Rolled-up Capacity Ovhd. Cost")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies the rolled-up manufacturing overhead cost of the item.';
                    Visible = false;
                }
                field("Rolled-up Scrap Cost"; Rec."Rolled-up Scrap Cost")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the cost of all component material that will eventually be scrapped to produce the parent item.';
                    Visible = false;
                }
                field("Single-Level Material Cost"; Rec."Single-Level Material Cost")
                {
                    ApplicationArea = Manufacturing;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the total material cost of all components on the parent item''s BOM.';
                    Visible = false;
                }
                field("Single-Level Capacity Cost"; Rec."Single-Level Capacity Cost")
                {
                    ApplicationArea = Manufacturing;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the capacity costs related to the item''s parent item only.';
                    Visible = false;
                }
                field("Single-Level Subcontrd. Cost"; Rec."Single-Level Subcontrd. Cost")
                {
                    ApplicationArea = Manufacturing;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the single-level cost of outsourcing operations to a subcontractor.';
                    Visible = false;
                }
                field("Single-Level Cap. Ovhd Cost"; Rec."Single-Level Cap. Ovhd Cost")
                {
                    ApplicationArea = Manufacturing;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the single-level capacity overhead cost.';
                    Visible = false;
                }
                field("Single-Level Mfg. Ovhd Cost"; Rec."Single-Level Mfg. Ovhd Cost")
                {
                    ApplicationArea = Manufacturing;
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies the single-level manufacturing overhead cost.';
                    Visible = false;
                }
                field("Single-Level Scrap Cost"; Rec."Single-Level Scrap Cost")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the cost of material at this BOM level that will eventually be scrapped in order to produce the parent item.';
                    Visible = false;
                }
                field("Total Cost"; Rec."Total Cost")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies the sum of all cost at this BOM level.';
                }
                field("Department"; Rec.Department)
                {
                    Visible = false;
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies the item''s Department in the Value Entry.';
                }

                field("ValueEntry Total Cost"; Rec."ValueEntry Total Cost")
                {
                    ApplicationArea = Assembly;
                    Caption = 'Total Value Entry Cost';
                    Visible = false;
                }
                field(Rate; Rec.Rate)
                {
                    ApplicationArea = Assembly;
                }
                field("Line Allocate Cost"; Rec."Line Allocate Cost")
                {
                    ApplicationArea = Assembly;
                    Caption = 'Allocation Amount';
                }

                field("G/L Acct"; Rec."GL Acct.")
                {
                    ApplicationArea = Assembly;
                    Caption = 'COGS Allocation Account';
                    Visible = false;
                }
                field("G/L Account Cost"; Rec."G/L Account Cost")
                {
                    ApplicationArea = Assembly;
                    Visible = false;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Assembly;
                }
                /* field("Total Cost per Item"; Rec."Total Cost per Item")
                {
                    ApplicationArea = Assembly;
                } */
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        DummyBOMWarningLog: Record "BOM Warning Log";
    begin
        IsParentExpr := not Rec."Is Leaf";

        HasWarning := not Rec.IsLineOk(false, DummyBOMWarningLog);
    end;

    trigger OnOpenPage()
    begin
        //RefreshPage();
    end;

    var
        IsParentExpr: Boolean;
        HasWarning: Boolean;
        Text001: Label 'There are no warnings.';

    local procedure ShowWarnings()
    var
        TempBOMWarningLog: Record "BOM Warning Log" temporary;
    begin
        if Rec.IsLineOk(true, TempBOMWarningLog) then
            Message(Text001)
        else
            PAGE.RunModal(PAGE::"BOM Warning Log", TempBOMWarningLog);
    end;

}

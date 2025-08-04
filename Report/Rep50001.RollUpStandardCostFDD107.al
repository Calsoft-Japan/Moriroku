report 50001 "Roll Up Standard Cost FDD107"
{
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Roll Up Standard Cost';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            //DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Costing Method";

            trigger OnPostDataItem()
            var
                NoFilter: Text;
                //FDD113
                CalcBOMTree: Codeunit "Calculate BOM Tree";
                HasBOM: Boolean;
                ShowByOption: Option;
                ItemFilter: Code[250];
                ShowBy: Enum "BOM Structure Show By";
                ConstantTxt: Label '''%1''', Locked = true;
                BOMBuff: Record "BOM Buffer" temporary;
                ItemCal: Record Item;
                AsmHeader: Record "Assembly Header";
                ProdOrderLine: Record "Prod. Order Line";
                BOMCostSharesCal: Record "BOM Cost shares Calculated";
                EntryNo: Integer;
            //FDD113
            begin
                TempItem107.Reset();
                TempItem107.CopyFilters(Item);
                NoFilter := TempItem107.GetFilter("No.");

                /* TempItem107.SetRange("Costing Method", Item."Costing Method"::Standard);
                TempItem107.SetFilter("Replenishment System", '%1|%2',
                  TempItem107."Replenishment System"::"Prod. Order",
                  TempItem107."Replenishment System"::Assembly); */
                if (NoFilter = '') and (ItemFilterStr <> '') then
                    TempItem107.SetFilter("No.", ItemFilterStr);

                if (NoFilter <> '') and (ItemFilterStr <> '') then
                    TempItem107.SetFilter("No.", StrSubstNo('(%1)&(%2)', ItemFilterStr, NoFilter));

                if not TempItem107.FindFirst() then exit;
                StdCostWksh.LockTable();
                Clear(CalcStdCost);
                CalcStdCost.SetProperties(CalculationDate, true, false, false, ToStdCostWkshName, true);
                CalcStdCost.CalcItems(TempItem107, TempItem);

                /* TempItem.SetFilter("Replenishment System", '%1|%2',
                  TempItem."Replenishment System"::"Prod. Order",
                  TempItem."Replenishment System"::Assembly); */

                //FDD113 BEGIN
                EntryNo := 0;
                //FDD113 END

                TempItem.CopyFilters(TempItem107);
                //TempItem.SetFilter("Standard Cost", '<>0');
                OnPreDataItemOnAfterSetTempItemFilter(TempItem);
                if TempItem.FindFirst() then
                    repeat
                        if not ItemFilterStr.Contains(StrSubstNo('<>"%1"', TempItem."No.")) then begin
                            UpdateStdCostWksh();
                            RolledUp := true;

                            //FDD113 BEGIN
                            BOMBuff.Reset();
                            BOMBuff.DeleteAll();
                            ItemCal.Copy(TempItem);
                            ItemFilter := '';
                            if ItemCal."No." <> '' then
                                ItemFilter := StrSubstNo(ConstantTxt, ItemCal."No.");
                            ShowBy := ShowBy::Item;

                            ShowByOption := ShowBy.AsInteger();
                            ShowBy := Enum::"BOM Structure Show By".FromInteger(ShowByOption);

                            ItemCal.SetFilter("No.", ItemFilter);
                            ItemCal.SetRange("Date Filter", 0D, WorkDate());
                            CalcBOMTree.SetItemFilter(ItemCal);

                            case ShowBy of
                                ShowBy::Item:
                                    begin
                                        ItemCal.FindSet();
                                        repeat
                                            HasBOM := ItemCal.HasBOM() or (ItemCal."Routing No." <> '')
                                        until HasBOM or (ItemCal.Next() = 0);

                                        //if not HasBOM then
                                        //    Error(Text000);
                                        if HasBOM then
                                            CalcBOMTree.GenerateTreeForItems(ItemCal, BOMBuff, 2);
                                    end;
                                ShowBy::Production:
                                    CalcBOMTree.GenerateTreeForProdLine(ProdOrderLine, BOMBuff, 2);
                                ShowBy::Assembly:
                                    CalcBOMTree.GenerateTreeForAsm(AsmHeader, BOMBuff, 2);
                            end;

                            BOMBuff.Reset();
                            if BOMBuff.FindFirst() then
                                repeat
                                    EntryNo := EntryNo + 1;
                                    BOMCostSharesCal.Init();
                                    BOMCostSharesCal.TransferFields(BOMBuff);
                                    BOMCostSharesCal."Entry No." := EntryNo;
                                    BOMCostSharesCal.Insert();
                                until BOMBuff.Next() = 0;

                            //FDD113 END
                        end;
                    until TempItem.Next() = 0;

                if not NoMessage then
                    if RolledUp then
                        Message(Text000)
                    else
                        Message(Text001);
            end;

            trigger OnAfterGetRecord()
            begin
                if not ItemValidation() then begin
                    if ItemFilterStr = '' then
                        ItemFilterStr := StrSubstNo('<>"%1"', Item."No.")
                    else
                        ItemFilterStr := ItemFilterStr + StrSubstNo('&<>"%1"', Item."No.");

                    Message(GetLastErrorText());
                    CurrReport.Skip();
                end;

                TempItem107.Init();
                TempItem107 := Item;
                TempItem107.Insert();
            end;

            trigger OnPreDataItem()
            begin
                Clear(ItemFilterStr);

                TempItem107.Reset();
                TempItem107.DeleteAll();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(CalculationDate; CalculationDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Calculation Date';
                        ToolTip = 'Specifies the date you want the cost shares to be calculated.';

                        trigger OnValidate()
                        begin
                            if CalculationDate = 0D then
                                Error(Text002);
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if CalculationDate = 0D then
                CalculationDate := WorkDate();
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    var
        StdCostWkshName: Record "Standard Cost Worksheet Name";
        BOMCostSharesCal: Record "BOM Cost shares Calculated";//FDD113
    begin
        RolledUp := false;

        if ToStdCostWkshName = '' then
            Error(Text003);
        StdCostWkshName.Get(ToStdCostWkshName);

        BOMCostSharesCal.Reset();//FDD113
        BOMCostSharesCal.DeleteAll();//FDD113
    end;

    var
        ItemFilterStr: Text;
        TempItem: Record Item temporary;
        TempItem107: Record Item temporary;
        StdCostWksh: Record "Standard Cost Worksheet";
        CalcStdCost: Codeunit "Calculate Standard Cost";
        CalculationDate: Date;
        ToStdCostWkshName: Code[10];
        RolledUp: Boolean;
        Text000: Label 'The standard costs have been rolled up successfully.';
        Text001: Label 'There is nothing to roll up.';
        Text002: Label 'You must enter a calculation date.';
        Text003: Label 'You must specify a worksheet name to roll up to.';
        NoMessage: Boolean;

    local procedure UpdateStdCostWksh()
    var
        Found: Boolean;
    begin
        Found := StdCostWksh.Get(ToStdCostWkshName, StdCostWksh.Type::Item, TempItem."No.");
        StdCostWksh.Validate("Standard Cost Worksheet Name", ToStdCostWkshName);
        StdCostWksh.Validate(Type, StdCostWksh.Type::Item);
        StdCostWksh.Validate("No.", TempItem."No.");
        StdCostWksh."New Standard Cost" := TempItem."Standard Cost";

        StdCostWksh."New Single-Lvl Material Cost" := TempItem."Single-Level Material Cost";
        StdCostWksh."New Single-Lvl Cap. Cost" := TempItem."Single-Level Capacity Cost";
        StdCostWksh."New Single-Lvl Subcontrd Cost" := TempItem."Single-Level Subcontrd. Cost";
        StdCostWksh."New Single-Lvl Cap. Ovhd Cost" := TempItem."Single-Level Cap. Ovhd Cost";
        StdCostWksh."New Single-Lvl Mfg. Ovhd Cost" := TempItem."Single-Level Mfg. Ovhd Cost";

        StdCostWksh."New Rolled-up Material Cost" := TempItem."Rolled-up Material Cost";
        StdCostWksh."New Rolled-up Cap. Cost" := TempItem."Rolled-up Capacity Cost";
        StdCostWksh."New Rolled-up Subcontrd Cost" := TempItem."Rolled-up Subcontracted Cost";
        StdCostWksh."New Rolled-up Cap. Ovhd Cost" := TempItem."Rolled-up Cap. Overhead Cost";
        StdCostWksh."New Rolled-up Mfg. Ovhd Cost" := TempItem."Rolled-up Mfg. Ovhd Cost";
        OnUpdateStdCostWkshOnAfterFieldsPopulated(StdCostWksh, TempItem);

        if Found then
            StdCostWksh.Modify(true)
        else
            StdCostWksh.Insert(true);
    end;

    procedure SetStdCostWksh(NewStdCostWkshName: Code[10])
    begin
        ToStdCostWkshName := NewStdCostWkshName;
    end;

    procedure Initialize(StdCostWkshName2: Code[10]; NoMessage2: Boolean)
    begin
        ToStdCostWkshName := StdCostWkshName2;
        NoMessage := NoMessage2;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateStdCostWkshOnAfterFieldsPopulated(var StdCostWksh: Record "Standard Cost Worksheet"; TempItem: Record Item temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPreDataItemOnAfterSetTempItemFilter(var TempItem: Record Item temporary)
    begin
    end;

    [TryFunction]
    procedure ItemValidation()
    var
        Text000: Label 'The standard cost cannot be calculated for Item [%1] as its Production BOM is not specified on the item master.';
        Text001: Label 'The standard cost cannot be calculated for Item [%1] as its Routing is not specified on the item master.';
        Text002: Label 'The standard cost cannot be calculated for Item [%1] as its Production BOM is blank.';
        Text003: Label 'The standard cost cannot be calculated for Item [%1] as its BOM Component Quantity is 0.';
        Text004: Label 'The standard cost cannot be calculated for Item [%1] as the Standard Cost of its component is 0.';
        Text005: Label 'The standard cost cannot be calculated for Item [%1] as its Routing is blank.';
        Text006: Label 'The standard cost cannot be calculated for Item [%1] as no run time set for its Routing operations.';
        Text007: Label 'The standard cost cannot be calculated for Item [%1] as its associated Machine Center does not have Unit Cost specified.';
        PrdBOMLine: Record "Production BOM Line";
        RoutingLine: Record "Routing Line";
        MCenter: Record "Machine Center";
        _Item: Record Item;
    begin
        if (Item."Replenishment System" <> Item."Replenishment System"::"Prod. Order") and (Item."Replenishment System" <> Item."Replenishment System"::Assembly) then
            exit;

        if Item."Production BOM No." = '' then
            Error(Text000, Item."No.")
        else begin
            PrdBOMLine.Reset();
            PrdBOMLine.SetRange(Type, PrdBOMLine.Type::Item);
            PrdBOMLine.SetRange("Production BOM No.", Item."Production BOM No.");
            if PrdBOMLine.IsEmpty then
                Error(Text002, Item."No.")
            else begin
                PrdBOMLine.SetFilter(Quantity, '<>0');

                if PrdBOMLine.FindFirst() then begin
                    repeat
                        _Item.Get(PrdBOMLine."No.");
                        if _Item."Standard Cost" = 0 then Error(Text004, Item."No.");//PrdBOMLine."No.");
                    until PrdBOMLine.Next() = 0;
                end else
                    Error(Text003, Item."No.");//PrdBOMLine."No.");
            end;
        end;

        if Item."Routing No." = '' then
            Error(Text001, Item."No.")
        else begin
            RoutingLine.Reset();
            RoutingLine.SetRange("Routing No.", Item."Routing No.");
            if RoutingLine.FindFirst() then begin
                repeat
                    if RoutingLine."Run Time" = 0 then
                        Error(Text006, Item."No.");

                    if RoutingLine.Type = RoutingLine.Type::"Machine Center" then begin
                        MCenter.Reset();
                        MCenter.Get(RoutingLine."No.");
                        if MCenter."Unit Cost" = 0 then Error(Text007, Item."No.");
                    end;
                until RoutingLine.Next() = 0;
            end
            else
                Error(Text005, Item."No.");
        end;
    end;
}

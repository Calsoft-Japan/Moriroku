codeunit 50000 "FDD106 Finishe Multi Prd Ord"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", OnCheckMissingOutput, '', false, false)]
    local procedure "Prod. Order Status Management_OnCheckMissingOutput"(var ProductionOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line"; var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; var ShowWarning: Boolean)
    begin
        /* if ShowWarning then
            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(Text004, ProductionOrder.TableCaption(), ProductionOrder."No."), false) then
                Error(Text005); //if running in Job Queue/WS, default button with NO then Interrupt with error

        ShowWarning := false;//Skip Original Confirm dialog  */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", OnCheckMissingConsumption, '', false, false)]
    local procedure "Prod. Order Status Management_OnCheckMissingConsumption"(var ProductionOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line"; var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; var ShowWarning: Boolean)
    begin
        /* if ShowWarning then
            if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(Text006, ProductionOrder.TableCaption(), ProductionOrder."No."), false) then
                Error(Text005);//if running in Job Queue/WS, default button with NO then Interrupt with error

        ShowWarning := false;//Skip Original Confirm dialog  */
    end;

    var
        Text004: Label '%1 %2 has not been finished. Output is missing. Do you still want to finish the order?';
        Text005: Label 'The update has been interrupted due to the warning.';
        Text006: Label '%1 %2 has not been finished. Consumption is missing. Do you still want to finish the order?';
        ConfirmManagement: Codeunit "Confirm Management";
}

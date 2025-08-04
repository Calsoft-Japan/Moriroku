codeunit 50009 FDD112BathPostSO
{

    procedure PostSaleOrder(var SalesHeader: Record "Sales Header"): Boolean
    var
        salePost: Codeunit "Sales-Post";
        result: Boolean;
    begin
        ClearLastError();
        result := true;
        if not salePost.Run(SalesHeader) then
            result := false;

        exit(result);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnRunOnBeforeCheckAndUpdate, '', false, false)]
    local procedure "Sales-Post_OnRunOnBeforeCheckAndUpdate"(var SalesHeader: Record "Sales Header")
    var
        SShipment: Record "Sales Shipment Header";
    begin
        /*      
        if not SalesHeader.Ship then exit;

        if SalesHeader."Package Tracking No." = '' then
            Error('Package Tracking No. can not be empty.');

        SShipment.Reset();
        SShipment.SetRange("Order No.", SalesHeader."No.");
        SShipment.SetRange("Package Tracking No.", SalesHeader."Package Tracking No.");
        if SShipment.FindFirst() then
            Error(StrSubstNo('Package Tracking No. [%1] in order [%2] already been shpped by shipment No. [%3], can not do shipment with same Tracking No.', SalesHeader."Package Tracking No.", SalesHeader."No.", SShipment."No.")); */
    end;

    [EventSubscriber(ObjectType::Table, Database::"BOM Buffer", OnTransferFromBOMCompCopyFields, '', false, false)]
    local procedure "BOM Buffer_OnTransferFromBOMCompCopyFields"(var BOMBuffer: Record "BOM Buffer"; BOMComponent: Record "BOM Component")
    begin
        BOMBuffer."Parent Item No." := BOMComponent."Parent Item No.";
    end;



}

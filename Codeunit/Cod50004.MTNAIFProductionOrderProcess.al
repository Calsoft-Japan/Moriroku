codeunit 50004 MTNAIFProductionOrderProcess
{
    //CS 2024/9/5 Channing.Zhou FDD304 CodeUnit for MTNA IF Production Order Process
    //CS 2025/10/21 Channing.Zhou FDD300 V7 Change the notification email contents, add error information page url.

    trigger OnRun()
    var
        ErrorRecCount: Integer;
    begin
        if ProcessAllData(ErrorRecCount) then begin
        end;
    end;

    [TryFunction]
    procedure ProcessAllData(var ErrorRecCount: Integer)
    var
        RecMTNA_IF_ProductionOrder: Record "MTNA_IF_ProductionOrder";
    begin
        RecMTNA_IF_ProductionOrder.Reset();
        RecMTNA_IF_ProductionOrder.SetRange(Status, RecMTNA_IF_ProductionOrder.Status::Ready);
        if RecMTNA_IF_ProductionOrder.FindFirst() then begin
            ProcessProductionOrderData(RecMTNA_IF_ProductionOrder, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcessProductionOrderData(var RecMTNA_IF_ProductionOrder: Record "MTNA_IF_ProductionOrder"; var ErrorRecCount: Integer)
    var
        RecProductionOrder: Record "Production Order";
        ErrorMessageText: Text;
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
    begin
        CalcLines := true;
        CalcRoutings := true;
        CalcComponents := true;
        Direction := Direction::Backward;
        CreateInbRqst := false;
        ErrorRecCount := 0;
        if RecMTNA_IF_ProductionOrder.FindFirst() then begin
            repeat
                if RecMTNA_IF_ProductionOrder.Status = RecMTNA_IF_ProductionOrder.Status::Ready then begin
                    RecMTNA_IF_ProductionOrder."Process start datetime" := CurrentDateTime;
                    RecProductionOrder.Reset();
                    RecProductionOrder.SetRange("No.", RecMTNA_IF_ProductionOrder."Production Order No.");
                    if RecProductionOrder.FindFirst() then begin
                        /*The following logic do not based on the FDD, please check the FDD for how to do if there is already a existsed Production Order*/
                        ErrorMessageText := RecProductionOrder."No." + ' Production Order No.  is existed.';
                        ProductionOrderErrorMessage(RecMTNA_IF_ProductionOrder, ErrorMessageText);
                        ErrorRecCount += 1;
                    end
                    else begin
                        RecProductionOrder.Reset();
                        Clear(RecProductionOrder);
                        if InsertProductionOrder(RecMTNA_IF_ProductionOrder, RecProductionOrder) then begin
                            if RefreshProductionOrder(RecMTNA_IF_ProductionOrder, RecProductionOrder) then begin
                                /*Need to add more process steps based on the FDD304*/
                                RecMTNA_IF_ProductionOrder.Status := RecMTNA_IF_ProductionOrder.Status::Completed;
                                RecMTNA_IF_ProductionOrder.Modify();
                            end
                            else begin
                                ErrorMessageText := GetLastErrorText();
                                RecMTNA_IF_ProductionOrder.Status := RecMTNA_IF_ProductionOrder.Status::Error;
                                RecMTNA_IF_ProductionOrder.SetErrormessage(ErrorMessageText);
                                RecMTNA_IF_ProductionOrder.Modify();
                                ProductionOrderErrorMessage(RecMTNA_IF_ProductionOrder, ErrorMessageText);
                                ErrorRecCount += 1;
                                PORollback(RecMTNA_IF_ProductionOrder);
                            end;
                        end
                        else begin
                            ErrorMessageText := GetLastErrorText();
                            RecMTNA_IF_ProductionOrder.Status := RecMTNA_IF_ProductionOrder.Status::Error;
                            RecMTNA_IF_ProductionOrder.SetErrormessage(ErrorMessageText);
                            RecMTNA_IF_ProductionOrder.Modify();
                            ProductionOrderErrorMessage(RecMTNA_IF_ProductionOrder, ErrorMessageText);
                            ErrorRecCount += 1;
                            PORollback(RecMTNA_IF_ProductionOrder);
                        end;
                    end;
                    RecMTNA_IF_ProductionOrder."Processed datetime" := CurrentDateTime;
                    RecMTNA_IF_ProductionOrder.Modify();
                end;
            until RecMTNA_IF_ProductionOrder.Next() = 0;
        end;
    end;

    [TryFunction]
    local procedure InsertProductionOrder(RecMTNA_IF_ProductionOrder: Record "MTNA_IF_ProductionOrder"; var RecProductionOrder: Record "Production Order")
    var
        NoSeries: Codeunit "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        GlobalProductionOrderNo := RecMTNA_IF_ProductionOrder."Production Order No.";

        RecProductionOrder.Reset();
        RecProductionOrder.Init();
        RecProductionOrder.Status := RecProductionOrder.Status::Released;
        RecProductionOrder.Validate("Source No.", RecMTNA_IF_ProductionOrder."Item No.");
        NoSeries.TestManual(RecProductionOrder.GetNoSeriesCode());
        RecProductionOrder.Validate("No.", RecMTNA_IF_ProductionOrder."Production Order No.");
        RecProductionOrder."Source Type" := RecProductionOrder."Source Type"::Item;
        RecProductionOrder.Validate("Due Date", RecMTNA_IF_ProductionOrder."APS Ending Date");
        RecProductionOrder.Validate("Location Code", RecMTNA_IF_ProductionOrder."Location Code");
        RecProductionOrder.Quantity := RecMTNA_IF_ProductionOrder.Quantity;
        RecProductionOrder."No. Series" := RecProductionOrder.GetNoSeriesCode();
        RecProductionOrder."APS Starting Date" := RecMTNA_IF_ProductionOrder."APS Starting Date";
        RecProductionOrder."APS Starting Time" := RecMTNA_IF_ProductionOrder."APS Starting Time";
        RecProductionOrder."APS Ending Date" := RecMTNA_IF_ProductionOrder."APS Ending Date";
        RecProductionOrder."APS Ending Time" := RecMTNA_IF_ProductionOrder."APS Ending Time";

        RecProductionOrder."Starting Date" := RecMTNA_IF_ProductionOrder."APS Starting Date";
        RecProductionOrder."Starting Time" := RecMTNA_IF_ProductionOrder."APS Starting Time";
        RecProductionOrder."Ending Date" := RecMTNA_IF_ProductionOrder."APS Ending Date";
        RecProductionOrder."Ending Time" := RecMTNA_IF_ProductionOrder."APS Ending Time";

        RecProductionOrder."Creation Date" := RecMTNA_IF_ProductionOrder."Order date";
        RecProductionOrder.Insert();

        NoSeriesLine.Reset();
        NoSeriesLine.SetRange("Series Code", RecProductionOrder."No. Series");
        if NoSeriesLine.FindFirst() then begin
            if NoSeriesLine."Last No. Used" < RecMTNA_IF_ProductionOrder."Production Order No." then begin
                NoSeriesLine."Last No. Used" := RecMTNA_IF_ProductionOrder."Production Order No.";
                NoSeriesLine.Modify();
            end;
        end;
    end;

    [TryFunction]
    local procedure RefreshProductionOrder(RecMTNA_IF_ProductionOrder: Record "MTNA_IF_ProductionOrder"; var RecProductionOrder: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderRtngLine: Record "Prod. Order Routing Line";
        ProdOrderComp: Record "Prod. Order Component";
        ProdOrder: Record "Production Order";
        ProdOrderStatusMgt: Codeunit "Prod. Order Status Management";
        RoutingNo: Code[20];
        ErrorOccured: Boolean;
        IsHandled: Boolean;
        CalcProdOrder: Codeunit "Calculate Prod. Order";
        CreateProdOrderLines: Codeunit "Create Prod. Order Lines";
        WhseProdRelease: Codeunit "Whse.-Production Release";
        WhseOutputProdRelease: Codeunit "Whse.-Output Prod. Release";
    begin
        RoutingNo := GetRoutingNo(RecProductionOrder);
        UpdateRoutingNo(RecProductionOrder, RoutingNo);

        ProdOrderLine.LockTable();
        CheckReservationExist();

        if CalcLines then begin
            if not IsHandled then
                if not CreateProdOrderLines.Copy(RecProductionOrder, Direction, RecProductionOrder."Variant Code", false) then
                    ErrorOccured := true;
        end else begin
            ProdOrderLine.SetRange(Status, ProdOrderLine.Status::Released);
            ProdOrderLine.SetRange("Prod. Order No.", RecMTNA_IF_ProductionOrder."Production Order No.");
            IsHandled := false;
            if not IsHandled then
                if CalcRoutings or CalcComponents then begin
                    if ProdOrderLine.Find('-') then
                        repeat
                            if CalcRoutings then begin
                                ProdOrderRtngLine.SetRange(Status, ProdOrderRtngLine.Status::Released);
                                ProdOrderRtngLine.SetRange("Prod. Order No.", RecMTNA_IF_ProductionOrder."Production Order No.");
                                ProdOrderRtngLine.SetRange("Routing Reference No.", ProdOrderLine."Routing Reference No.");
                                ProdOrderRtngLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
                                if ProdOrderRtngLine.FindSet(true) then
                                    repeat
                                        ProdOrderRtngLine.SetSkipUpdateOfCompBinCodes(true);
                                        ProdOrderRtngLine.Delete(true);
                                    until ProdOrderRtngLine.Next() = 0;
                            end;
                            if CalcComponents then begin
                                ProdOrderComp.SetRange(Status, ProdOrderComp.Status::Released);
                                ProdOrderComp.SetRange("Prod. Order No.", RecMTNA_IF_ProductionOrder."Production Order No.");
                                ProdOrderComp.SetRange("Prod. Order Line No.", ProdOrderLine."Line No.");
                                ProdOrderComp.DeleteAll(true);
                            end;
                        until ProdOrderLine.Next() = 0;
                    if ProdOrderLine.Find('-') then
                        repeat
                            if CalcComponents then
                                CheckProductionBOMStatus(ProdOrderLine."Production BOM No.", ProdOrderLine."Production BOM Version Code");
                            if CalcRoutings then
                                CheckRoutingStatus(ProdOrderLine."Routing No.", ProdOrderLine."Routing Version Code");
                            ProdOrderLine."Due Date" := RecMTNA_IF_ProductionOrder."APS Ending Date";
                            IsHandled := false;
                            if not IsHandled then
                                if not CalcProdOrder.Calculate(ProdOrderLine, Direction, CalcRoutings, CalcComponents, false, false) then
                                    ErrorOccured := true;
                        until ProdOrderLine.Next() = 0;
                end;
        end;

        ProdOrderStatusMgt.FlushProdOrder(RecProductionOrder, RecProductionOrder.Status::Released, WorkDate());
        WhseProdRelease.Release(RecProductionOrder);
        if CreateInbRqst then
            WhseOutputProdRelease.Release(RecProductionOrder);

        UpdateAPS(RecMTNA_IF_ProductionOrder);
    end;

    local procedure CheckReservationExist()
    var
        ProdOrderLine2: Record "Prod. Order Line";
        ProdOrderComp2: Record "Prod. Order Component";
    begin
        // Not allowed to refresh if reservations exist
        if not (CalcLines or CalcComponents) then
            exit;

        ProdOrderLine2.SetRange(Status, ProdOrderLine2.Status::Released);
        ProdOrderLine2.SetRange("Prod. Order No.", GlobalProductionOrderNo);
        if ProdOrderLine2.Find('-') then
            repeat
                if CalcLines then begin
                    ProdOrderLine2.CalcFields("Reserved Qty. (Base)");
                    if ProdOrderLine2."Reserved Qty. (Base)" <> 0 then
                        if ShouldCheckReservedQty(
                             ProdOrderLine2."Prod. Order No.", 0, Database::"Prod. Order Line",
                             ProdOrderLine2.Status, ProdOrderLine2."Line No.", Database::"Prod. Order Component")
                        then
                            ProdOrderLine2.TestField("Reserved Qty. (Base)", 0);
                end;

                if CalcComponents then begin
                    ProdOrderComp2.SetRange(Status, ProdOrderLine2.Status);
                    ProdOrderComp2.SetRange("Prod. Order No.", ProdOrderLine2."Prod. Order No.");
                    ProdOrderComp2.SetRange("Prod. Order Line No.", ProdOrderLine2."Line No.");
                    ProdOrderComp2.SetAutoCalcFields("Reserved Qty. (Base)");
                    if ProdOrderComp2.Find('-') then
                        repeat
                            if ProdOrderComp2."Reserved Qty. (Base)" <> 0 then
                                if ShouldCheckReservedQty(
                                     ProdOrderComp2."Prod. Order No.", ProdOrderComp2."Line No.",
                                     Database::"Prod. Order Component", ProdOrderComp2.Status,
                                     ProdOrderComp2."Prod. Order Line No.", Database::"Prod. Order Line")
                                then
                                    ProdOrderComp2.TestField("Reserved Qty. (Base)", 0);
                        until ProdOrderComp2.Next() = 0;
                end;
            until ProdOrderLine2.Next() = 0;
    end;

    local procedure ShouldCheckReservedQty(ProdOrderNo: Code[20]; LineNo: Integer; SourceType: Integer; Status: Enum "Production Order Status"; ProdOrderLineNo: Integer;
                                                                                                                    SourceType2: Integer): Boolean
    var
        ReservEntry: Record "Reservation Entry";
    begin
        ReservEntry.SetSourceFilter(SourceType, Status.AsInteger(), ProdOrderNo, LineNo, true);
        ReservEntry.SetSourceFilter('', ProdOrderLineNo);
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
        if ReservEntry.FindFirst() then begin
            ReservEntry.Get(ReservEntry."Entry No.", not ReservEntry.Positive);
            exit(
              not ((ReservEntry."Source Type" = SourceType2) and
                   (ReservEntry."Source ID" = ProdOrderNo) and (ReservEntry."Source Subtype" = Status.AsInteger())));
        end;

        exit(false);
    end;

    local procedure UpdateRoutingNo(var ProductionOrder: Record "Production Order"; RoutingNo: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        if RoutingNo <> ProductionOrder."Routing No." then begin
            ProductionOrder."Routing No." := RoutingNo;
            ProductionOrder.Modify();
        end;
    end;

    local procedure CheckProductionBOMStatus(ProdBOMNo: Code[20]; ProdBOMVersionNo: Code[20])
    var
        ProductionBOMHeader: Record "Production BOM Header";
        ProductionBOMVersion: Record "Production BOM Version";
    begin
        if ProdBOMNo = '' then
            exit;

        if ProdBOMVersionNo = '' then begin
            ProductionBOMHeader.Get(ProdBOMNo);
            ProductionBOMHeader.TestField(Status, ProductionBOMHeader.Status::Certified);
        end else begin
            ProductionBOMVersion.Get(ProdBOMNo, ProdBOMVersionNo);
            ProductionBOMVersion.TestField(Status, ProductionBOMVersion.Status::Certified);
        end;
    end;

    local procedure CheckRoutingStatus(RoutingNo: Code[20]; RoutingVersionNo: Code[20])
    var
        RoutingHeader: Record "Routing Header";
        RoutingVersion: Record "Routing Version";
    begin
        if RoutingNo = '' then
            exit;

        if RoutingVersionNo = '' then begin
            RoutingHeader.Get(RoutingNo);
            RoutingHeader.TestField(Status, RoutingHeader.Status::Certified);
        end else begin
            RoutingVersion.Get(RoutingNo, RoutingVersionNo);
            RoutingVersion.TestField(Status, RoutingVersion.Status::Certified);
        end;
    end;

    procedure InitializeRequest(Direction2: Option Forward,Backward; CalcLines2: Boolean; CalcRoutings2: Boolean; CalcComponents2: Boolean; CreateInbRqst2: Boolean)
    begin
        Direction := Direction2;
        CalcLines := CalcLines2;
        CalcRoutings := CalcRoutings2;
        CalcComponents := CalcComponents2;
        CreateInbRqst := CreateInbRqst2;
    end;

    local procedure IsComponentPicked(ProdOrder: Record "Production Order"): Boolean
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        ProdOrderComp.SetRange(Status, ProdOrder.Status);
        ProdOrderComp.SetRange("Prod. Order No.", ProdOrder."No.");
        ProdOrderComp.SetFilter("Qty. Picked", '<>0');
        exit(not ProdOrderComp.IsEmpty);
    end;

    local procedure GetRoutingNo(ProdOrder: Record "Production Order") RoutingNo: Code[20]
    var
        Item: Record Item;
        StockkeepingUnit: Record "Stockkeeping Unit";
        Family: Record Family;
    begin
        RoutingNo := ProdOrder."Routing No.";
        case ProdOrder."Source Type" of
            ProdOrder."Source Type"::Item:
                begin
                    if Item.Get(ProdOrder."Source No.") then
                        RoutingNo := Item."Routing No.";
                    if StockkeepingUnit.Get(ProdOrder."Location Code", ProdOrder."Source No.", ProdOrder."Variant Code") and
                        (StockkeepingUnit."Routing No." <> '')
                    then
                        RoutingNo := StockkeepingUnit."Routing No.";
                end;
            ProdOrder."Source Type"::Family:
                if Family.Get(ProdOrder."Source No.") then
                    RoutingNo := Family."Routing No.";
        end;

    end;

    [TryFunction]
    local procedure ProductionOrderErrorMessage(var RecMTNA_IF_ProductionOrder: Record MTNA_IF_ProductionOrder; ErrorMessageText: Text)
    var
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
        pagMTNA_IF_ProductionOrderErr: Page "MTNA_IF_ProductionOrderErr";
        RecRef: RecordRef;
    begin
        RecMTNA_IF_ProductionOrder.Status := RecMTNA_IF_ProductionOrder.Status::Error;
        RecMTNA_IF_ProductionOrder.SetErrormessage('Error occurred when inserting Production order. The detailed error message is: ' + ErrorMessageText);
        RecMTNA_IF_ProductionOrder.Modify();
        RecRef.GetTable(RecMTNA_IF_ProductionOrder);
        if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF ProductionOrder Process Insert', RecMTNA_IF_ProductionOrder.Plant, Format(RecMTNA_IF_ProductionOrder."Entry No."),
            RecMTNA_IF_ProductionOrder."Process start datetime", ErrorMessageText, pagMTNA_IF_ProductionOrderErr.Caption, pagMTNA_IF_ProductionOrderErr.ObjectId(false), RecRef) then begin
        end;
    end;

    local procedure UpdateAPS(RecMTNA_IF_ProductionOrder: Record "MTNA_IF_ProductionOrder")
    var
        RecProdOrderRtngLine: Record "Prod. Order Routing Line";
        RecProductionOrderLine: Record "Production Order";
        RecProdOrderLine: Record "Prod. Order Line";
        RecMachineCenter: Record "Machine Center";
        MachineCenterCode1: Text;
        MachineCenterCode2: Text;
        MachineCenterCode3: Text;
        MachineCenterCode: Text;
        changeMachineCenter: Boolean;
        recordSec: Integer;
        secModValue: Integer;
    begin
        RecMachineCenter.Reset();
        RecMachineCenter.SetRange("Work Center No.", RecMTNA_IF_ProductionOrder."Work Center Code");
        if not RecMachineCenter.IsEmpty() then begin
            RecMachineCenter.FindSet();
            recordSec := 0;
            repeat
                if recordSec = 0 then begin
                    MachineCenterCode1 := RecMachineCenter."No.";
                end
                else if recordSec = 1 then begin
                    MachineCenterCode2 := RecMachineCenter."No.";
                end
                else if recordSec = 2 then begin
                    MachineCenterCode3 := RecMachineCenter."No.";
                end;
                recordSec := recordSec + 1;
            until RecMachineCenter.Next() = 0;
        end;

        RecProdOrderRtngLine.Reset();
        RecProdOrderRtngLine.SetRange("Prod. Order No.", RecMTNA_IF_ProductionOrder."Production Order No.");
        RecProdOrderRtngLine.SetCurrentKey("Operation No.");
        if not RecProdOrderRtngLine.IsEmpty() then begin
            RecProdOrderRtngLine.FindSet();
            recordSec := 0;
            repeat
                changeMachineCenter := false;
                if RecProdOrderRtngLine."Work Center No." <> RecMTNA_IF_ProductionOrder."Work Center Code" then begin
                    changeMachineCenter := true;
                end;
                if (changeMachineCenter) then begin
                    secModValue := recordSec MOD 3;
                    if secModValue = 0 then begin
                        MachineCenterCode := MachineCenterCode1;
                    end
                    else if secModValue = 1 then begin
                        MachineCenterCode := MachineCenterCode2;
                    end
                    else if secModValue = 2 then begin
                        MachineCenterCode := MachineCenterCode3;
                    end;
                    RecProdOrderRtngLine.Type := RecProdOrderRtngLine.Type::"Machine Center";
                    RecProdOrderRtngLine.Validate("No.", MachineCenterCode);
                    RecProdOrderRtngLine.Modify();
                end;
                recordSec := recordSec + 1;
            until RecProdOrderRtngLine.Next() = 0;
        end;

        RecProdOrderRtngLine.Reset();
        RecProdOrderRtngLine.SetRange("Prod. Order No.", RecMTNA_IF_ProductionOrder."Production Order No.");
        if RecProdOrderRtngLine.FindFirst() then begin
            repeat
                RecProdOrderRtngLine."APS Ending Date" := RecMTNA_IF_ProductionOrder."APS Ending Date";
                RecProdOrderRtngLine."APS Ending Time" := RecMTNA_IF_ProductionOrder."APS Ending Time";
                RecProdOrderRtngLine."APS Starting Date" := RecMTNA_IF_ProductionOrder."APS Starting Date";
                RecProdOrderRtngLine."APS Starting Time" := RecMTNA_IF_ProductionOrder."APS Starting Time";

                RecProdOrderRtngLine."Starting Date" := RecMTNA_IF_ProductionOrder."APS Starting Date";
                RecProdOrderRtngLine."Starting Time" := RecMTNA_IF_ProductionOrder."APS Starting Time";
                RecProdOrderRtngLine."Ending Date" := RecMTNA_IF_ProductionOrder."APS Ending Date";
                RecProdOrderRtngLine."Ending Time" := RecMTNA_IF_ProductionOrder."APS Ending Time";

                //RecProdOrderRtngLine."Setup Time Unit of Meas. Code" := 'SEC';
                //RecProdOrderRtngLine."Run Time Unit of Meas. Code" := 'SEC';
                RecProdOrderRtngLine.Modify();
            until RecProdOrderRtngLine.Next() = 0;
        end;

        RecProductionOrderLine.Reset();
        RecProductionOrderLine.SetRange("Source No.", RecMTNA_IF_ProductionOrder."Item No.");
        RecProductionOrderLine.SetRange(Status, RecProductionOrderLine.Status::Released);
        RecProductionOrderLine.SetRange("No.", RecMTNA_IF_ProductionOrder."Production Order No.");
        RecProductionOrderLine.SetRange("Source Type", RecProductionOrderLine."Source Type"::Item);
        if RecProductionOrderLine.FindFirst() then begin
            RecProductionOrderLine.Validate("Due Date", RecMTNA_IF_ProductionOrder."APS Ending Date");
            RecProductionOrderLine."Starting Date" := RecMTNA_IF_ProductionOrder."APS Starting Date";
            RecProductionOrderLine."Starting Time" := RecMTNA_IF_ProductionOrder."APS Starting Time";
            RecProductionOrderLine."Ending Date" := RecMTNA_IF_ProductionOrder."APS Ending Date";
            RecProductionOrderLine."Ending Time" := RecMTNA_IF_ProductionOrder."APS Ending Time";
            RecProductionOrderLine."Starting Date-Time" := CreateDateTime(RecMTNA_IF_ProductionOrder."APS Starting Date", RecMTNA_IF_ProductionOrder."APS Starting Time");
            RecProductionOrderLine."Ending Date-Time" := CreateDateTime(RecMTNA_IF_ProductionOrder."APS Ending Date", RecMTNA_IF_ProductionOrder."APS Ending Time");
            RecProductionOrderLine.Modify(true);
        end;

        RecProdOrderLine.Reset();
        RecProdOrderLine.SetRange("Item No.", RecMTNA_IF_ProductionOrder."Item No.");
        RecProdOrderLine.SetRange(Status, RecProductionOrderLine.Status::Released);
        RecProdOrderLine.SetRange("Prod. Order No.", RecMTNA_IF_ProductionOrder."Production Order No.");
        if RecProdOrderLine.FindFirst() then begin
            RecProdOrderLine.Validate("Due Date", RecMTNA_IF_ProductionOrder."APS Ending Date");
            RecProdOrderLine."Starting Date" := RecMTNA_IF_ProductionOrder."APS Starting Date";
            RecProdOrderLine."Starting Time" := RecMTNA_IF_ProductionOrder."APS Starting Time";
            RecProdOrderLine."Ending Date" := RecMTNA_IF_ProductionOrder."APS Ending Date";
            RecProdOrderLine."Ending Time" := RecMTNA_IF_ProductionOrder."APS Ending Time";
            RecProdOrderLine."Starting Date-Time" := CreateDateTime(RecMTNA_IF_ProductionOrder."APS Starting Date", RecMTNA_IF_ProductionOrder."APS Starting Time");
            RecProdOrderLine."Ending Date-Time" := CreateDateTime(RecMTNA_IF_ProductionOrder."APS Ending Date", RecMTNA_IF_ProductionOrder."APS Ending Time");
            RecProdOrderLine.Modify(true);
        end;
    end;

    local procedure PORollback(RecMTNA_IF_ProductionOrder: Record "MTNA_IF_ProductionOrder")
    var
        ProdOrder: Record "Production Order";
    begin

        ProdOrder.Reset();
        ProdOrder.SetRange("No.", RecMTNA_IF_ProductionOrder."Production Order No.");
        ProdOrder.SetRange("APS Ending Date", RecMTNA_IF_ProductionOrder."APS Ending Date");
        ProdOrder.SetRange("APS Ending Time", RecMTNA_IF_ProductionOrder."APS Ending Time");
        ProdOrder.SetRange("APS Starting Date", RecMTNA_IF_ProductionOrder."APS Starting Date");
        ProdOrder.SetRange("APS Starting Time", RecMTNA_IF_ProductionOrder."APS Starting Time");
        ProdOrder.SetRange("Creation date", RecMTNA_IF_ProductionOrder."Order Date");
        if ProdOrder.FindFirst() then begin
            ProdOrder.DeleteProdOrderRelations();
            ProdOrder.Delete();
        end;
    end;

    var
        CalcLines: Boolean;
        CalcRoutings: Boolean;
        CalcComponents: Boolean;
        Direction: Option Forward,Backward;
        CreateInbRqst: Boolean;
        GlobalProductionOrderNo: Code[20];
        GlobalDueDate: Date;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Prod. Order Lines", OnBeforeProdOrderLineInsert, '', false, false)]
    local procedure "Create Prod. Order Lines_OnBeforeProdOrderLineInsert"(var ProdOrderLine: Record "Prod. Order Line"; var ProductionOrder: Record "Production Order"; SalesLineIsSet: Boolean; var SalesLine: Record "Sales Line")
    begin
        ProdOrderLine."APS Ending Date" := ProductionOrder."APS Ending Date";
        ProdOrderLine."APS Ending Time" := ProductionOrder."APS Ending Time";
        ProdOrderLine."APS Starting Date" := ProductionOrder."APS Starting Date";
        ProdOrderLine."APS Starting Time" := ProductionOrder."APS Starting Time";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Routing Line", OnAfterWorkCenterTransferFields, '', false, false)]
    local procedure "Prod. Order Routing Line_OnAfterWorkCenterTransferFields"(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; WorkCenter: Record "Work Center")
    var
        RecCapacityUOM: Record "Capacity Unit of Measure";
    begin
        RecCapacityUOM.Reset();
        if not RecCapacityUOM.Get('SEC') then begin
            RecCapacityUOM.Reset();
            RecCapacityUOM.Init();
            RecCapacityUOM.Code := 'SEC';
            RecCapacityUOM.Description := 'SEC';
            RecCapacityUOM.Type := RecCapacityUOM.Type::Seconds;
            RecCapacityUOM.Insert();
        end;
        ProdOrderRoutingLine."Run Time Unit of Meas. Code" := 'SEC';
    end;

}

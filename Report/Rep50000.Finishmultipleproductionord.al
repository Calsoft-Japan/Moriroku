report 50000 "Finish multiple production ord"
{
    ApplicationArea = All;
    Caption = 'Finish Multiple Production Orders';
    Description = 'Finish Multiple Production Orders';
    UsageCategory = Tasks;
    ProcessingOnly = True;
    dataset
    {
        dataitem(ProductionOrder; "Production Order")
        {
            DataItemTableView = where(Status = filter(Released), Blocked = const(true));

            trigger OnPreDataItem()
            begin
                Clear(ErrorText);
            end;

            trigger OnAfterGetRecord()
            var
                CR, LF : Char;
                CurTime: DateTime;
                EntryNo: Integer;
                JobQueue: Record "Job Queue Entry";
                PrdLine: Record "Prod. Order Line";
                LineError: Boolean;
                CurErrText: Text;
                Text009: Label 'You cannot finish line %1 on %2 %3. It has consumption or capacity posted with no output.';
                Text004: Label '%1 %2 has not been finished. Some output is still missing. ';
            begin
                CR := 13;
                LF := 10;
                CurTime := CurrentDateTime;
                Clear(CurErrText);

                LineError := false;
                PrdLine.Reset();
                PrdLine.SetRange(Status, ProductionOrder.Status);
                PrdLine.SetRange("Prod. Order No.", ProductionOrder."No.");
                if PrdLine.FindSet() then
                    repeat
                        if PrdLine."Finished Quantity" = 0 then begin
                            LineError := true;
                            CurErrText := CurErrText + StrSubstNo('%1:  The update has been interrupted to respect the warning.', "No.") + CR + LF;
                            ErrorText := ErrorText + StrSubstNo('%1:  The update has been interrupted to respect the warning.', "No.") + CR + LF;
                        end;

                        if not ProdOrderStatusMgt.OutputExists(PrdLine) then begin
                            if ProdOrderStatusMgt.MatrOrCapConsumpExists(PrdLine) then begin
                                LineError := true;
                                CurErrText := CurErrText + StrSubstNo(Text009, PrdLine."Line No.", ProductionOrder.TableCaption(), PrdLine."Prod. Order No.") + CR + LF;
                                ErrorText := ErrorText + StrSubstNo(Text009, PrdLine."Line No.", ProductionOrder.TableCaption(), PrdLine."Prod. Order No.") + CR + LF;
                            end;
                        end;

                        if (PrdLine."Finished Quantity" = 0) and (CurErrText.EndsWith('The update has been interrupted to respect the warning.' + CR + LF)) then begin
                            CurErrText := CurErrText + StrSubstNo(Text004, ProductionOrder.TableCaption(), ProductionOrder."No.") + CR + LF;
                            ErrorText := ErrorText + StrSubstNo(Text004, ProductionOrder.TableCaption(), ProductionOrder."No.") + CR + LF;
                        end;
                    until PrdLine.Next() = 0;


                if not LineError then
                    if (not CHGStatus(ProductionOrder, false)) then begin
                        //Error handle here
                        LineError := true;
                        CurErrText := CurErrText + StrSubstNo('%1: ', "No.") + GetLastErrorText() + CR + LF;
                        ErrorText := ErrorText + StrSubstNo('%1: ', "No.") + GetLastErrorText() + CR + LF;
                    end;

                // if LineError or (not CHGStatus(ProductionOrder, false)) then begin
                //     //Error handle here

                //     if not LineError then
                //         ErrorText := ErrorText + StrSubstNo('%1: ', "No.") + GetLastErrorText() + CR + LF;

                if LineError then begin
                    EntryNo := 1;
                    LogEntry.Reset();
                    if LogEntry.FindLast() then
                        EntryNo := LogEntry."Entry No." + 1;

                    LogEntry.Init();
                    LogEntry."Entry No." := EntryNo;
                    LogEntry.Status := LogEntry.Status::Error;
                    LogEntry.ID := CreateGuid();
                    LogEntry."User ID" := UserId;
                    LogEntry."Object ID to Run" := Report::"Finish multiple production ord";
                    LogEntry."Object Type to Run" := LogEntry."Object Type to Run"::Report;
                    LogEntry."Object Caption to Run" := 'Finish Multiple Production Orders';
                    LogEntry."Start Date/Time" := CurTime;
                    LogEntry."End Date/Time" := CurrentDateTime;
                    LogEntry."Error Message" := CurErrText.Replace('..', '.');//StrSubstNo('%1: ', "No.") + GetLastErrorText();
                    LogEntry.Insert();

                    JobQueue.Reset();
                    JobQueue.SetRange("Object Type to Run", JobQueue."Object Type to Run"::Report);
                    JobQueue.SetRange("Object ID to Run", Report::"Finish multiple production ord");
                    if JobQueue.FindFirst() then
                        SentMails(LogEntry, StrSubstNo('Name:%1 Error:%2', JobQueue.Description, LogEntry."Error Message"), ProductionOrder."Location Code");
                end;
            end;
        }
    }

    trigger OnPreReport()
    var
        ErrorMessage: Record "Error Message";
        JobQueue: Record "Job Queue Entry";
    begin
        Clear(ErrorText);

        JobQueue.Reset();
        JobQueue.SetRange("Object Type to Run", JobQueue."Object Type to Run"::Report);
        JobQueue.SetRange("Object ID to Run", Report::"Finish multiple production ord");
        if JobQueue.FindFirst() then begin
            JobQueue."Error Message" := '';
            JobQueue.Modify();

            ErrorMessage.Reset();
            //ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Error);
            ErrorMessage.SetRange("Register ID", JobQueue."Error Message Register Id");
            if ErrorMessage.FindSet() then ErrorMessage.DeleteAll();

            Commit();
        end;
    end;

    trigger OnPostReport()
    begin
        Commit();

        if ErrorText <> '' then
            Error(ErrorText);
    end;


    [CommitBehavior(CommitBehavior::Ignore)]
    [TryFunction]
    procedure CHGStatus(PrdOrd: Record "Production Order"; ReqUpdUnitCost: Boolean)
    begin
        ProdOrderStatusMgt.ChangeProdOrderStatus(PrdOrd, PrdOrd.Status::Finished, Today(), ReqUpdUnitCost);
    end;

    var
        LogEntry: Record "Job Queue Log Entry";
        ProdOrderStatusMgt: Codeunit "Prod. Order Status Management";
        ErrorText: Text;
        ProdOrderCompRemainToPickErr: Label 'You cannot finish production order no. %1 because there is an outstanding pick for one or more components.', Comment = '%1: Production Order No.';


    local procedure SetProdOrderCompFilters(var ProdOrderComponent: Record "Prod. Order Component"; ProductionOrder: Record "Production Order")
    begin
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
        ProdOrderComponent.SetFilter("Remaining Quantity", '<>0');
    end;

    [TryFunction]
    local procedure CheckNothingRemainingToPickForProdOrderComp(ProdOrderComponent: Record "Prod. Order Component")
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        WarehouseActivityLine.SetFilter(
          "Activity Type", '%1|%2|%3',
          WarehouseActivityLine."Activity Type"::"Invt. Movement", WarehouseActivityLine."Activity Type"::"Invt. Pick",
          WarehouseActivityLine."Activity Type"::Pick);
        WarehouseActivityLine.SetSourceFilter(
          Database::"Prod. Order Component", ProdOrderComponent.Status.AsInteger(), ProdOrderComponent."Prod. Order No.",
          ProdOrderComponent."Prod. Order Line No.", ProdOrderComponent."Line No.", true);
        WarehouseActivityLine.SetRange("Original Breakbulk", false);
        WarehouseActivityLine.SetRange("Breakbulk No.", 0);
        WarehouseActivityLine.SetFilter("Qty. Outstanding (Base)", '<>%1', 0);
        if not WarehouseActivityLine.IsEmpty() then
            Error(ProdOrderCompRemainToPickErr, ProdOrderComponent."Prod. Order No.");
    end;

    local procedure RtngWillFlushComp(ProdOrderComp: Record "Prod. Order Component"): Boolean
    var
        ProdOrderRtngLine: Record "Prod. Order Routing Line";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        if ProdOrderComp."Routing Link Code" = '' then
            exit;

        ProdOrderLine.Get(ProdOrderComp.Status, ProdOrderComp."Prod. Order No.", ProdOrderComp."Prod. Order Line No.");

        ProdOrderRtngLine.SetCurrentKey("Prod. Order No.", Status, "Flushing Method");
        ProdOrderRtngLine.SetRange("Flushing Method", ProdOrderRtngLine."Flushing Method"::Backward);
        ProdOrderRtngLine.SetRange(Status, ProdOrderRtngLine.Status::Released);
        ProdOrderRtngLine.SetRange("Prod. Order No.", ProdOrderComp."Prod. Order No.");
        ProdOrderRtngLine.SetRange("Routing Link Code", ProdOrderComp."Routing Link Code");
        ProdOrderRtngLine.SetRange("Routing No.", ProdOrderLine."Routing No.");
        ProdOrderRtngLine.SetRange("Routing Reference No.", ProdOrderLine."Routing Reference No.");
        exit(not ProdOrderRtngLine.IsEmpty());
    end;

    [TryFunction]
    local procedure SentMails(var JobQueueLog: Record "Job Queue Log Entry"; Details: Text[2048]; LocCode: Text)
    var
        Rec_UserSetup: Record "User Setup";
        MailingList: List of [Text];
        CU_Email: Codeunit Email;
        CU_EmailMessage: Codeunit "Email Message";
        CuEmailAccount: Codeunit "Email Account";
        TempCuEmailAccount: record "Email Account" temporary;
        SubjectLbl: Label 'Job Queue [Finish Mulitple Production Orders] Failed in Business Central';
        BodyLblDeptHod: Label 'Hi Team, <br> <br> This is to inform you in Business Central some of the job queue failed. <br> Kindly view the failed job queue %1 this by visiting <a href="%2"> </a> here. <br><a href="%3"> </a>';
        PRDLink, AppLink : Text;
        CompanyInfo: Record "Company Information";
        MTNA_Email: Record "MTNA IF Email Notification";
        Location: Record Location;
    begin
        Clear(AppLink);
        /*Clear(Rec_UserSetup);
        Rec_UserSetup.Reset();
         Rec_UserSetup.SetRange("IT Department", true);
        if Rec_UserSetup.FindSet() then
            repeat
                if Rec_UserSetup."E-Mail" <> '' then
                    MailingList.Add(Rec_UserSetup."E-Mail");
            until Rec_UserSetup.Next() = 0;
        CompanyInfo.Get();
        if CompanyInfo."Notificaiton E-Mail" <> '' then
            MailingList.Add(CompanyInfo."Notificaiton E-Mail")
        else
            exit; */

        //MailingList.Add('erika.majima@calsoft.com');
        Location.Reset();
        Location.SetRange(Code, LocCode);
        if Location.FindFirst() then begin
            MTNA_Email.Reset();

            if Location.Plant = Location.Plant::Nil then
                exit;

            if Location.Plant = Location.Plant::G then begin//MTNA_SITE_GR
                MTNA_Email.SetRange("Plant", MTNA_Email.Plant::G);

                if MTNA_Email.FindFirst() then
                    if MTNA_Email."E-Mail".Trim() <> '' then
                        MailingList.Add(MTNA_Email."E-Mail");
            end;

            if Location.Plant = Location.Plant::A then begin//MTNA_SITE_AN
                MTNA_Email.SetRange("Plant", MTNA_Email.Plant::A);

                if MTNA_Email.FindFirst() then
                    if MTNA_Email."E-Mail".Trim() <> '' then
                        MailingList.Add(MTNA_Email."E-Mail");
            end;

            if Location.Plant = Location.Plant::R then begin//MTNA_SITE_RA 
                MTNA_Email.SetRange("Plant", MTNA_Email.Plant::R);

                if MTNA_Email.FindFirst() then
                    if MTNA_Email."E-Mail".Trim() <> '' then
                        MailingList.Add(MTNA_Email."E-Mail");
            end;

            if Location.Plant = Location.Plant::L then begin//MTNA_SITE_LI
                MTNA_Email.SetRange("Plant", MTNA_Email.Plant::L);

                if MTNA_Email.FindFirst() then
                    if MTNA_Email."E-Mail".Trim() <> '' then
                        MailingList.Add(MTNA_Email."E-Mail");
            end;
        end;

        if MailingList.Count = 0 then exit;

        PRDLink := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Released Production Order", ProductionOrder, true);
        AppLink := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Job Queue Log Entries", JobQueueLog, true);

        if MailingList.Count <> 0 then begin
            Clear(CU_EmailMessage);
            CU_EmailMessage.Create(MailingList,
                                    StrSubstNo(SubjectLbl),
                                    StrSubstNo(BodyLblDeptHod, Details, AppLink, PRDLink), true);

            CuEmailAccount.GetAllAccounts(TempCuEmailAccount);
            TempCuEmailAccount.Reset;
            TempCuEmailAccount.SetRange(Name, 'Current User');
            if TempCuEmailAccount.FindFirst() then
                CU_Email.Send(CU_EmailMessage, TempCuEmailAccount)//."Account Id", TempCuEmailAccount.Connector)
            else
                CU_Email.Send(CU_EmailMessage);
        end;
    end;

}

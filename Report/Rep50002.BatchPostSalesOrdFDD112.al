report 50002 "Batch Post Sales Ord FDD112"
{
    ApplicationArea = All;
    Caption = 'Batch Sales Invoice Posting';
    UsageCategory = Tasks;
    ProcessingOnly = true;
    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = sorting("No.") where("Shipped Not Invoiced" = Const(true));
            RequestFilterFields = "No.", "Sell-to Customer No.";
            dataitem(SalesShipmentHeader; "Sales Shipment Header")
            {
                DataItemLink = "Order No." = field("No.");
                DataItemTableView = sorting("Package Tracking No.") where("Package Tracking No." = filter('<>""'));

                trigger OnAfterGetRecord()
                var
                    SInvHeader: Record "Sales Invoice Header";
                    TotalQuery: Query ShipmentLineQtyQueryFDD112;
                    SOrdLine: Record "Sales Line";
                    ShpLine: Record "Sales Shipment Line";
                    SumQty: Decimal;
                    InvQtyBase: Decimal;
                    MaxQtyToInvoice: Decimal;
                begin
                    if (Cur_PkgTkNo = '') or (Cur_PkgTkNo <> SalesShipmentHeader."Package Tracking No.") then
                        Cur_PkgTkNo := SalesShipmentHeader."Package Tracking No."
                    else
                        CurrReport.Skip();

                    SInvHeader.Reset();
                    SInvHeader.SetRange("Order No.", "Order No.");
                    SInvHeader.SetRange("Package Tracking No.", SalesShipmentHeader."Package Tracking No.");
                    if not SInvHeader.IsEmpty() then
                        CurrReport.Skip();

                    SalesHeader.Validate("Posting Date", SalesShipmentHeader."Posting Date");
                    SalesHeader."Package Tracking No." := SalesShipmentHeader."Package Tracking No.";
                    SalesHeader.Modify();

                    TotalQuery.SetQueryFilter(SalesHeader."No.", SalesShipmentHeader."Package Tracking No.");
                    if TotalQuery.Open() then begin
                        hasSthPost := false;

                        SOrdLine.Reset();
                        SOrdLine.SetRange("Document Type", SalesHeader."Document Type");
                        SOrdLine.SetRange("Document No.", SalesHeader."No.");
                        SOrdLine.SetFilter(Type, '<>0');
                        if SOrdLine.FindFirst() then
                            repeat
                                SOrdLine.Validate("Qty. to Ship", 0);
                                SOrdLine.Validate("Qty. to Invoice", 0);
                                SOrdLine.Modify();
                            until SOrdLine.Next() = 0;

                        while TotalQuery.Read() do begin
                            SOrdLine.Reset();
                            SOrdLine.SetRange("Document Type", SalesHeader."Document Type");
                            SOrdLine.SetRange("Document No.", SalesHeader."No.");
                            SOrdLine.SetRange("Line No.", TotalQuery.Order_Line_No_);
                            SOrdLine.SetFilter(Type, '<>0');//0 = "Sales Line Type"::" "
                            if SOrdLine.FindFirst() then begin
                                SOrdLine.Validate("Qty. to Ship", 0);

                                if TotalQuery.Quantity <> SOrdLine.MaxQtyToInvoice() then begin
                                    MaxQtyToInvoice := SOrdLine.MaxQtyToInvoice();
                                    InvQtyBase := SOrdLine.CalcBaseQty(TotalQuery.Quantity, 'Qty. to Invoice', 'Qty. to Invoice (Base)');
                                    if (SOrdLine."Quantity (Base)" = (SOrdLine."Qty. Invoiced (Base)" + InvQtyBase)) and (TotalQuery.Quantity > 0) then
                                        Error(StrSubstNo('SO:%1 Line:%2 Qty To Inv:%3 Max Inv Qty:%7 Qty Inv Base:%4 Invoiced (Base):%5 Quantity Base:%6 to be out of balance.', SOrdLine."Document No.", SOrdLine."Line No.", TotalQuery.Quantity, InvQtyBase, SOrdLine."Qty. Invoiced (Base)", SOrdLine."Quantity (Base)", MaxQtyToInvoice));
                                end;

                                if (TotalQuery.Quantity * SOrdLine.Quantity < 0) or
                                         (Abs(TotalQuery.Quantity) > Abs(SOrdLine.MaxQtyToInvoice())) then
                                    Error(StrSubstNo('SO:%1 Line:%2; You cannot invoice more than %3 units.(Try to invoice %4 units)', SOrdLine."Document No.", SOrdLine."Line No.", SOrdLine.MaxQtyToInvoice(), TotalQuery.Quantity))
                                else
                                    SOrdLine.Validate("Qty. to Invoice", TotalQuery.Quantity);//SalesShipmentLine.Quantity);

                                //SOrdLine."Qty. to Invoice" := TotalQuery.Quantity;
                                SOrdLine.Modify();

                                hasSthPost := true;
                            end;
                        end;

                        if hasSthPost then begin
                            PostCurSaleShipment();
                        end;
                    end;
                end;

            }

            trigger OnAfterGetRecord()
            begin
                Cur_PkgTkNo := '';
            end;
        }
    }

    [TryFunction]
    procedure PostSaleOrder()
    var
        salePost: Codeunit "Sales-Post";
    begin
        salePost.Run(SalesHeader);
    end;


    procedure PostCurSaleShipment()
    var
        salePost: Codeunit "Sales-Post";
        JobQueue: Record "Job Queue Entry";
        LogEntry: Record "Job Queue Log Entry";
        ErrorMessage: Record "Error Message";
        FDD112BathPostSO: Codeunit FDD112BathPostSO;
        JQErrRegID: Guid;
        CR, LF : Char;
        CurErrText: Text;
        EntryNo: Integer;
        CurTime: DateTime;
        CurSONo: Text;
    begin
        if hasSthPost then begin
            SalesHeader.Ship := false;
            SalesHeader.Receive := false;
            SalesHeader.Invoice := true;
            CurSONo := SalesHeader."No.";
            Commit();
            if not FDD112BathPostSO.PostSaleOrder(SalesHeader) then begin
                //if not PostSaleOrder() then begin
                if GetLastErrorText() = '' then begin

                    ErrorMessage.Reset();
                    ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Error);//"Sales-Post"(CodeUnit 80).OnRun(Trigger)

                    JobQueue.Reset();
                    JobQueue.SetRange("Object Type to Run", JobQueue."Object Type to Run"::Report);
                    JobQueue.SetRange("Object ID to Run", Report::"Batch Post Sales Ord FDD112");
                    if JobQueue.FindFirst() then begin
                        ErrorMessage.SetRange("Register ID", JobQueue."Error Message Register Id");

                        ErrorMessage.SetAscending("Created On", true);
                        if ErrorMessage.FindLast() then begin
                            CurErrText := StrSubstNo('Sales Order:%1, Shipment:%2 : %3', CurSONo, SalesShipmentHeader."No.", ErrorMessage.Message);
                            ErrorText := ErrorText + StrSubstNo('Sales Order:%1, Shipment:%2 : %3', CurSONo, SalesShipmentHeader."No.", ErrorMessage.Message) + CR + LF;
                        end else begin
                            CurErrText := StrSubstNo('Sales Order:%1, Shipment:%2 : %3', CurSONo, SalesShipmentHeader."No.", JobQueue."Error Message");
                            ErrorText := ErrorText + StrSubstNo('Sales Order:%1, Shipment:%2 : %3', CurSONo, SalesShipmentHeader."No.", JobQueue."Error Message") + CR + LF;
                        end;
                    end;
                end else begin
                    CurErrText := StrSubstNo('Sales Order:%1, Shipment:%2 : %3', CurSONo, SalesShipmentHeader."No.", GetLastErrorText());
                    ErrorText := ErrorText + StrSubstNo('Sales Order:%1, Shipment:%2 : %3', CurSONo, SalesShipmentHeader."No.", GetLastErrorText()) + CR + LF;
                end;

                EntryNo := 1;
                CurTime := CurrentDateTime;
                LogEntry.Reset();
                if LogEntry.FindLast() then
                    EntryNo := LogEntry."Entry No." + 1;

                LogEntry.Init();
                LogEntry."Entry No." := EntryNo;
                LogEntry.Status := LogEntry.Status::Error;
                LogEntry.ID := CreateGuid();
                LogEntry."User ID" := UserId;
                LogEntry."Object ID to Run" := Report::"Batch Post Sales Ord FDD112";
                LogEntry."Object Type to Run" := LogEntry."Object Type to Run"::Report;
                LogEntry."Object Caption to Run" := 'Batch Sales Invoice Posting';
                LogEntry."Start Date/Time" := CurTime;
                LogEntry."End Date/Time" := CurrentDateTime;
                LogEntry."Error Message" := CurErrText.Replace('..', '.');//StrSubstNo('%1: ', "No.") + GetLastErrorText();
                LogEntry.Insert();

                /* JobQueue.Reset();
                JobQueue.SetRange("Object Type to Run", JobQueue."Object Type to Run"::Report);
                JobQueue.SetRange("Object ID to Run", Report::"Batch Post Sales Ord FDD112");
                if JobQueue.FindFirst() then
                    SentMails(LogEntry, StrSubstNo('Name:%1 Error:%2', JobQueue.Description, LogEntry."Error Message"), SalesHeader."Location Code"); */
            end;
        end;
    end;

    trigger OnPreReport()
    var
        ErrorMessage: Record "Error Message";
        JobQueue: Record "Job Queue Entry";
    begin
        Clear(ErrorText);

        JobQueue.Reset();
        JobQueue.SetRange("Object Type to Run", JobQueue."Object Type to Run"::Report);
        JobQueue.SetRange("Object ID to Run", Report::"Batch Post Sales Ord FDD112");
        if JobQueue.FindFirst() then begin
            JobQueue."Error Message" := '';
            JobQueue.Modify();

            ErrorMessage.Reset();
            //ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Error);
            ErrorMessage.SetRange("Register ID", JobQueue."Error Message Register Id");
            if ErrorMessage.FindSet() then ErrorMessage.DeleteAll();
        end;
    end;

    trigger OnPostReport()
    begin
        Commit();

        if ErrorText <> '' then
            Error(ErrorText);
    end;

    var
        ErrorText: Text;
        curSLineNo: Integer;
        hasSthPost: Boolean;
        Cur_PkgTkNo: Text;
    //     PkgQty: Decimal;

    /*
        [TryFunction]
        local procedure SentMails(var JobQueueLog: Record "Job Queue Log Entry"; Details: Text[2048]; LocCode: Text)
        var
            Rec_UserSetup: Record "User Setup";
            MailingList: List of [Text];
            CU_Email: Codeunit Email;
            CU_EmailMessage: Codeunit "Email Message";
            CuEmailAccount: Codeunit "Email Account";
            TempCuEmailAccount: record "Email Account" temporary;
            SubjectLbl: Label 'Job Queue [Batch Sales Invoice Posting] Failed in Business Central';
            BodyLblDeptHod: Label 'Hi Team, <br> <br> This is to inform you in Business Central some of the job queue failed. <br> Kindly view the failed job queue %1 this by visiting <a href="%2"> </a> here. <br><a href="%3"> </a> <br><a href="%4"> </a>';
            SOLink, SHPLink, AppLink : Text;
            CompanyInfo: Record "Company Information";
            MTNA_Email: Record "MTNA IF Email Notification";
            Location: Record Location;
        begin
            Clear(AppLink);
            // Clear(Rec_UserSetup);
            // Rec_UserSetup.Reset();
            //  Rec_UserSetup.SetRange("IT Department", true);
            // if Rec_UserSetup.FindSet() then
            //     repeat
            //         if Rec_UserSetup."E-Mail" <> '' then
            //             MailingList.Add(Rec_UserSetup."E-Mail");
            //     until Rec_UserSetup.Next() = 0;  
            // CompanyInfo.Get();
            // if CompanyInfo."Notificaiton E-Mail" <> '' then
            //     MailingList.Add(CompanyInfo."Notificaiton E-Mail")
            // else
                exit;

            //MailingList.Add('erika.majima@calsoft.com');

            Location.Reset();
            Location.Get(LocCode);
            if Location.FindFirst() then begin
                MTNA_Email.Reset();
                if Location.MTNA_SITE_GR then begin
                    MTNA_Email.SetRange("Plant", MTNA_Email.Plant::G);

                    if MTNA_Email.FindFirst() then
                        if MTNA_Email."E-Mail".Trim() <> '' then
                            MailingList.Add(MTNA_Email."E-Mail");
                end;

                if Location.MTNA_SITE_AN then begin
                    MTNA_Email.SetRange("Plant", MTNA_Email.Plant::A);

                    if MTNA_Email.FindFirst() then
                        if MTNA_Email."E-Mail".Trim() <> '' then
                            MailingList.Add(MTNA_Email."E-Mail");
                end;

                if Location.MTNA_SITE_RA then begin
                    MTNA_Email.SetRange("Plant", MTNA_Email.Plant::R);

                    if MTNA_Email.FindFirst() then
                        if MTNA_Email."E-Mail".Trim() <> '' then
                            MailingList.Add(MTNA_Email."E-Mail");
                end;

                if Location.MTNA_SITE_LI then begin
                    MTNA_Email.SetRange("Plant", MTNA_Email.Plant::L);

                    if MTNA_Email.FindFirst() then
                        if MTNA_Email."E-Mail".Trim() <> '' then
                            MailingList.Add(MTNA_Email."E-Mail");
                end;
            end;

            if MailingList.Count = 0 then exit;

            SOLink := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Sales Order", SalesHeader, true);
            SHPLink := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Posted Sales Shipment", SalesShipmentHeader, true);
            AppLink := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Job Queue Log Entries", JobQueueLog, true);

            if MailingList.Count <> 0 then begin
                Clear(CU_EmailMessage);
                CU_EmailMessage.Create(MailingList,
                                        StrSubstNo(SubjectLbl),
                                        StrSubstNo(BodyLblDeptHod, Details, AppLink, SOLink, AppLink), true);

                CuEmailAccount.GetAllAccounts(TempCuEmailAccount);
                TempCuEmailAccount.Reset;
                TempCuEmailAccount.SetRange(Name, 'Current User');
                if TempCuEmailAccount.FindFirst() then
                    CU_Email.Send(CU_EmailMessage, TempCuEmailAccount)//."Account Id", TempCuEmailAccount.Connector)
                else
                    CU_Email.Send(CU_EmailMessage);
            end;
        end;*/

}

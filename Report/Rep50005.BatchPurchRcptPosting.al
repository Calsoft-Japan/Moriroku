report 50005 "Purchase Invoice Posting"
{
    ApplicationArea = All;
    Caption = 'Purchase Invoice Posting';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(PurchRcptHeader; "Purch. Rcpt. Header")
        {

            trigger OnAfterGetRecord()
            var
                PurHeader: Record "Purchase Header";
                PurLine: Record "Purchase Line";
                PurRcptLine: Record "Purch. Rcpt. Line";
                PurPost: Codeunit "Purch.-Post";

                UOMMgt: Codeunit "Unit of Measure Management";
                QtyToInv: Decimal;
                InvQtyBase: Decimal;
                MaxQtyToInvoice: Decimal;
                MaxQtyToInvoiceBase: Decimal;
                ReleasePurchDoc: Codeunit "Release Purchase Document";

                hasStPost: Boolean;
            begin

                PurHeader.Reset();
                if PurHeader.Get(PurHeader."Document Type"::Order, PurchRcptHeader."Order No.") then begin
                    PurHeader.CalcFields("Amt. Rcd. Not Invoiced (LCY)", "Received Not Invoiced");
                    if PurHeader."Amt. Rcd. Not Invoiced (LCY)" = 0 then//PurHeader."Received Not Invoiced" = false
                        CurrReport.Skip();

                    ReleasePurchDoc.PerformManualReopen(PurHeader);
                    PurHeader.Ship := false;
                    PurHeader.Receive := false;
                    PurHeader.Invoice := true;
                    PurHeader.Validate("Posting Date", PurchRcptHeader."Posting Date");
                    PurHeader.Validate("Document Date", PurchRcptHeader."Posting Date");//"Document Date"
                    PurHeader.Validate("Vendor Invoice No.", StrSubstNo('%1%2', PurchRcptHeader."Vendor Shipment No.", CopyStr(PurchRcptHeader."No.", StrLen(PurchRcptHeader."No.") - 8, 9)));
                    PurHeader.Modify();

                    hasStPost := false;
                    PurRcptLine.Reset();
                    PurRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
                    PurRcptLine.SetFilter(Type, '<>0');
                    PurRcptLine.SetFilter("Qty. Rcd. Not Invoiced", '>0');
                    if PurRcptLine.FindFirst() then begin
                        PurLine.Reset();
                        PurLine.SetRange("Document Type", PurLine."Document Type"::Order);
                        PurLine.SetRange("Document No.", PurchRcptHeader."Order No.");
                        if PurLine.FindFirst() then
                            repeat
                                PurLine.Validate("Qty. to Receive", 0);
                                PurLine.Validate("Qty. to Invoice", 0);
                                PurLine.Modify();
                            until PurLine.Next() = 0;

                        repeat
                            PurLine.Reset();
                            PurLine.SetRange("Document Type", PurLine."Document Type"::Order);
                            PurLine.SetRange("Document No.", PurchRcptHeader."Order No.");
                            PurLine.SetRange("Line No.", PurRcptLine."Order Line No.");
                            if PurLine.FindFirst() then begin
                                PurLine.Validate("Qty. to Receive", 0);

                                QtyToInv := UOMMgt.RoundAndValidateQty(Abs(PurRcptLine.Quantity), PurLine."Qty. Rounding Precision", PurLine.FieldCaption("Qty. to Invoice"));

                                InvQtyBase := UOMMgt.CalcBaseQty(
                                           PurLine."No.", PurLine."Variant Code", PurLine."Unit of Measure Code", QtyToInv, PurLine."Qty. per Unit of Measure", PurLine."Qty. Rounding Precision (Base)",
                                           PurLine.FieldCaption("Qty. Rounding Precision"), PurLine.FieldCaption("Qty. to Invoice"), PurLine.FieldCaption("Qty. to Invoice (Base)"));
                                //InvQtyBase := PurLine.CalcBaseQty(QtyToInv, PurLine.FieldCaption("Qty. to Invoice"), PurLine.FieldCaption("Qty. to Invoice (Base)"));
                                MaxQtyToInvoice := PurLine.MaxQtyToInvoice();
                                MaxQtyToInvoiceBase := PurLine.MaxQtyToInvoiceBase();

                                if (QtyToInv * PurLine.Quantity < 0) or (Abs(QtyToInv) > Abs(MaxQtyToInvoice)) then
                                    Error(StrSubstNo('PO:%1 Line:%2 Qty To Inv:%3 Max Inv Qty:%4 Qty in Rcept:%5  Qty to Invoice can''t more than MaxInvQty.', PurLine."Document No.", PurLine."Line No.", QtyToInv, MaxQtyToInvoice, PurRcptLine.Quantity));

                                if (MaxQtyToInvoiceBase * PurLine."Quantity (Base)" < 0) or (Abs(InvQtyBase) > Abs(MaxQtyToInvoiceBase)) then
                                    Error('PO:%1 Line:%2 Qty To Inv(Base):%3 Max Inv Qty(Base):%4 Qty in Rcept:%5 You cannot invoice more than %4 base units.', PurLine."Document No.", PurLine."Line No.", InvQtyBase, MaxQtyToInvoiceBase, PurRcptLine.Quantity);


                                PurLine.Validate("Qty. to Invoice", Abs(QtyToInv));//PurRcptLine.Quantity);
                                PurLine.Modify();
                                hasStPost := true;
                            end;
                        until PurRcptLine.Next() = 0;
                    end;

                    //Commit();
                    //PurPost.Run(PurHeader);
                    IF hasStPost then
                        PostCurPurchRcpt(PurHeader);
                end;
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }

    }
    var
        ErrorText: Text;

    procedure PostCurPurchRcpt(PurchaseHeader: Record "Purchase Header")
    var
        JobQueue: Record "Job Queue Entry";
        LogEntry: Record "Job Queue Log Entry";
        ErrorMessage: Record "Error Message";
        FDD119BatchPostPO: Codeunit FDD119BatchPostPO;
        JQErrRegID: Guid;
        CR, LF : Char;
        CurErrText: Text;
        EntryNo: Integer;
        CurTime: DateTime;
        CurPONo: Text;
    begin
        /* PurchaseHeader.Ship := false;
        PurchaseHeader.Receive := false;
        PurchaseHeader.Invoice := true; */
        CurPONo := PurchaseHeader."No.";
        Commit();
        if not FDD119BatchPostPO.PostPurchaseOrder(PurchaseHeader) then begin
            //if not PostSaleOrder() then begin
            if GetLastErrorText() = '' then begin

                ErrorMessage.Reset();
                ErrorMessage.SetRange("Message Type", ErrorMessage."Message Type"::Error);//"Sales-Post"(CodeUnit 80).OnRun(Trigger)

                JobQueue.Reset();
                JobQueue.SetRange("Object Type to Run", JobQueue."Object Type to Run"::Report);
                JobQueue.SetRange("Object ID to Run", Report::"Batch Post Purch. Ret. Orders");
                if JobQueue.FindFirst() then begin
                    ErrorMessage.SetRange("Register ID", JobQueue."Error Message Register Id");

                    ErrorMessage.SetAscending("Created On", true);
                    if ErrorMessage.FindLast() then begin
                        CurErrText := StrSubstNo('Purchase Order:%1, Receipt:%2 : %3', CurPONo, PurchRcptHeader."No.", ErrorMessage.Message);
                        ErrorText := ErrorText + StrSubstNo('Purchase Order:%1, Receipt:%2 : %3', CurPONo, PurchRcptHeader."No.", ErrorMessage.Message) + CR + LF;
                    end else begin
                        CurErrText := StrSubstNo('Purchase Order:%1, Receipt:%2 : %3', CurPONo, PurchRcptHeader."No.", JobQueue."Error Message");
                        ErrorText := ErrorText + StrSubstNo('Purchase Order:%1, Receipt:%2 : %3', CurPONo, PurchRcptHeader."No.", JobQueue."Error Message") + CR + LF;
                    end;
                end;
            end else begin
                CurErrText := StrSubstNo('Purchase Order:%1, Receipt:%2 : %3', CurPONo, PurchRcptHeader."No.", GetLastErrorText());
                ErrorText := ErrorText + StrSubstNo('Purchase Order:%1, Receipt:%2 : %3', CurPONo, PurchRcptHeader."No.", GetLastErrorText()) + CR + LF;
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
            LogEntry."Object ID to Run" := Report::"Purchase Invoice Posting";
            LogEntry."Object Type to Run" := LogEntry."Object Type to Run"::Report;
            LogEntry."Object Caption to Run" := 'Batch Purch. Rcpt. Posting';
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

    trigger OnPreReport()
    var
        ErrorMessage: Record "Error Message";
        JobQueue: Record "Job Queue Entry";
    begin
        Clear(ErrorText);

        JobQueue.Reset();
        JobQueue.SetRange("Object Type to Run", JobQueue."Object Type to Run"::Report);
        JobQueue.SetRange("Object ID to Run", Report::"Purchase Invoice Posting");
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

}

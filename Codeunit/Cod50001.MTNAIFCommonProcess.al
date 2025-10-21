codeunit 50001 MTNA_IF_CommonProcess
{
    //CS 2024/8/13 Channing.Zhou FDD300 CodeUnit for MTNA IF Common Process
    //CS 2025/10/21 Channing.Zhou FDD300 V7 Change the notification email contents, add error information page url.
    var
        CuEmailMessage: codeunit "Email Message";
        CuEmail: codeunit Email;

    trigger OnRun()
    begin
        if ProcessAllData() then begin
        end;
    end;

    [TryFunction]
    procedure ProcessAllData()
    var
        CuMTNAIFOutputJournalProcess: Codeunit "MTNAIFOutputJournalProcess";
        CuMTNAIFPurchaseOrderProcess: Codeunit MTNAIFPurchaseOrderProcess;
        CuMTNAIFProductionOrderProcess: Codeunit MTNAIFProductionOrderProcess;
        CUMTNAIFPurchaseReceivingProcess: Codeunit MTNAIFPurchaseReceivingProcess;
        CUMTNAIFStandardCostProcess: Codeunit MTNAIFStandardCostProcess;
        CUMTNAIFItemJournalProcess: Codeunit MTNAIFItemJournalProcess;
        CUMTNAIFItemReclasJournalProcess: Codeunit MTNAIFItemReclasJournalProcess;
        ErrorRecCount: Integer;
    begin
        if not CuMTNAIFOutputJournalProcess.ProcessAllData(ErrorRecCount) then begin
        end;

        if not CuMTNAIFPurchaseOrderProcess.ProcessAllData(ErrorRecCount) then begin
        end;

        if not CuMTNAIFProductionOrderProcess.ProcessAllData(ErrorRecCount) then begin
        end;

        if not CUMTNAIFPurchaseReceivingProcess.ProcessAllData(ErrorRecCount) then begin
        end;

        if not CUMTNAIFStandardCostProcess.ProcessAllData(ErrorRecCount) then begin
        end;

        if not CUMTNAIFItemJournalProcess.ProcessAllData(ErrorRecCount) then begin
        end;

        if not CUMTNAIFItemReclasJournalProcess.ProcessAllData(ErrorRecCount) then begin
        end;
    end;

    [TryFunction]
    procedure SendNotificationEmail(FunctionName: Text; Plant: Enum "MTNA IF Plant"; RecordID: Text; ProcessStartTime: DateTime; Errormessage: Text; PageCaption: Text; PageId: Text; var RecRef: RecordRef)
    var
        subject, body : text;
        RecCompanyInfo: Record "Company Information";
        RecMTNAIFEmailNotification: Record "MTNA IF Email Notification";
        isSent: boolean;
        chr10: char;
        chr13: char;
        dateStr: text;
    begin
        RecMTNAIFEmailNotification.Reset();
        RecMTNAIFEmailNotification.SetRange(Plant, Plant);
        if RecMTNAIFEmailNotification.FindFirst() then begin
            chr10 := 10;
            chr13 := 13;
            dateStr := format(ProcessStartTime, 22, '<Month,2>/<Day,2>/<Year4> <Hours12,2>:<Minutes,2>:<Seconds,2> <AM/PM>');
            subject := 'Error Notification - ' + FunctionName + ' Execution Failure';
            body := '<p>An error occurred in the ' + FunctionName + ' function at ' + dateStr + '. </p><br/>' +
                    '<p>Details:</p>';
            body += '<p>Function Name: ' + FunctionName + '</p>';
            RecCompanyInfo.Get();
            if RecCompanyInfo.Name <> '' then begin
                body += '<p>Company: ' + RecCompanyInfo.Name + '</p>';
            end
            else begin
                body += '<p>Company: UnKnow</p>';
            end;
            body += '<p>Plant: ' + Format(Plant) + '</p>';
            body += '<p>Record ID: ' + RecordID + '</p>';
            body += '<p>Error Description: ' + Errormessage + '</p>';
            body += '<p>Next Steps:</p>' +
                    '<p>Please review the related page for further details and corrective actions.</p>' +
                    '<p><a href="' + GetPageUrl(PageId, RecRef) + '" target="_blank">' + PageCaption + '</a></p>';

            isSent := SeendEmail(RecMTNAIFEmailNotification."E-Mail", '', subject, body);
        end;
    end;

    procedure GetPageUrl(PageId: Text; var RecRef: RecordRef): Text
    var
        Url: Text;
        RecMN: Record MTNA_IF_ItemJournal;
        RealPageId: Integer;
    begin
        if Evaluate(RealPageId, PageId) then begin
            Url := System.GetUrl(
                ClientType::Current,            // Use current client (Web) context
                CompanyName(),                  // Company name (exact display name)
                ObjectType::Page,               // Target object type
                RealPageId,                     // Page ID
                RecRef,                         // Optional: record to open (must be set to the right key)
                true                            // Include current filters in the URL when possible
            );
            exit(Url);
        end
        else begin
            exit('');
        end;
    end;


    [TryFunction]
    procedure SeendEmail(EmailTo: Text; EmailCC: Text; EmailSubject: Text; EmailBody: Text)
    var
        EmailToList: List of [Text];
        EmailCCList: List of [Text];
        EmailBCCList: List of [Text];
        CuEmailAccount: Codeunit "Email Account";
        TempCuEmailAccount: record "Email Account" temporary;
        isSent: boolean;
    begin
        if EmailCC <> '' then begin
            CuEmailMessage.Create(EmailTo, EmailSubject, EmailBody, true);
        end
        else begin
            EmailToList := EmailTo.Split(';');
            EmailCCList := EmailCC.Split(';');
            CuEmailMessage.Create(EmailToList, EmailSubject, EmailBody, true, EmailCCList, EmailBCCList);
        end;
        CuEmailAccount.GetAllAccounts(TempCuEmailAccount);
        TempCuEmailAccount.Reset;
        TempCuEmailAccount.SetRange(Name, 'Current User');
        if TempCuEmailAccount.FindFirst() then
            isSent := CuEmail.Send(CuEmailMessage, TempCuEmailAccount."Account Id", TempCuEmailAccount.Connector)
        else
            isSent := CuEmail.Send(CuEmailMessage);
    end;
}

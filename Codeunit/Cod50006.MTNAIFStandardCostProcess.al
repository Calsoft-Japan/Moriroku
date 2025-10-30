codeunit 50006 MTNAIFStandardCostProcess
{
    //CS 2024/8/13 Channing.Zhou FDD306 CodeUnit for MTNA IF Standard Cost Process
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
        RecMTNA_IF_StandardCost: Record "MTNA_IF_StandardCost";
        RecMTNAIFConfiguration: record "MTNA IF Configuration";
        MaxProcCount: Integer;
    begin
        RecMTNA_IF_StandardCost.Reset();
        RecMTNA_IF_StandardCost.SetRange(Status, RecMTNA_IF_StandardCost.Status::Ready);
        if RecMTNA_IF_StandardCost.FindFirst() then begin
            MaxProcCount := 0;
            RecMTNAIFConfiguration.Reset();
            RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Standard cost");
            if RecMTNAIFConfiguration.FindFirst() then begin
                MaxProcCount := RecMTNAIFConfiguration."Max. records to process";
            end;
            ProcessStandardCostData(RecMTNA_IF_StandardCost, MaxProcCount, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcessStandardCostData(var RecMTNA_IF_StandardCost: Record "MTNA_IF_StandardCost"; MaxProcCount: Integer; var ErrorRecCount: Integer)
    var
        RecStandardCostWorksheet: Record "Standard Cost Worksheet";
        ErrorMessageText: Text;
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
        RecLastProcessingIFStandarCost: Record "MTNA_IF_StandardCost" temporary;
        pagMTNA_IF_StandardCostErr: Page "MTNA_IF_StandardCostErr";
        RecRef: RecordRef;
        proccessedCount: Integer;
    begin
        ErrorRecCount := 0;
        proccessedCount := 0;
        RecMTNA_IF_StandardCost.SetCurrentKey(Plant, "Standard Cost Worksheet Name");
        RecLastProcessingIFStandarCost.Init();
        RecLastProcessingIFStandarCost.Insert();
        if RecMTNA_IF_StandardCost.FindFirst() then begin
            repeat
                proccessedCount += 1;
                if RecMTNA_IF_StandardCost.Status = RecMTNA_IF_StandardCost.Status::Ready then begin
                    RecMTNA_IF_StandardCost."Process start datetime" := CurrentDateTime;
                    if (RecLastProcessingIFStandarCost.Plant <> RecMTNA_IF_StandardCost.Plant)
                    or (RecLastProcessingIFStandarCost."Standard Cost Worksheet Name" <> RecMTNA_IF_StandardCost."Standard Cost Worksheet Name") then begin
                        RecLastProcessingIFStandarCost.Plant := RecMTNA_IF_StandardCost.Plant;
                        RecLastProcessingIFStandarCost."Standard Cost Worksheet Name" := RecMTNA_IF_StandardCost."Standard Cost Worksheet Name";
                        RecStandardCostWorksheet.Reset();
                        RecStandardCostWorksheet.SetRange("Standard Cost Worksheet Name", RecMTNA_IF_StandardCost."Standard Cost Worksheet Name");
                        if RecStandardCostWorksheet.FindFirst() then begin
                            RecStandardCostWorksheet.DeleteAll();
                        end;
                    end;
                    Clear(RecStandardCostWorksheet);
                    if InsertStandardCostWorksheet(RecMTNA_IF_StandardCost, RecStandardCostWorksheet) then begin
                        RecMTNA_IF_StandardCost.Status := RecMTNA_IF_StandardCost.Status::Completed;
                        RecMTNA_IF_StandardCost.Modify();
                    end
                    else begin
                        ErrorMessageText := GetLastErrorText();
                        RecMTNA_IF_StandardCost.Status := RecMTNA_IF_StandardCost.Status::Error;
                        RecMTNA_IF_StandardCost.SetErrormessage('Error occurred when inserting Standard Cost Worksheet Line. The detailed error message is: ' + ErrorMessageText);
                        RecMTNA_IF_StandardCost.Modify();
                        RecRef.GetTable(RecMTNA_IF_StandardCost);
                        if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF Standard Cost Worksheet Process Insert', RecMTNA_IF_StandardCost.Plant, Format(RecMTNA_IF_StandardCost."Entry No."),
                            RecMTNA_IF_StandardCost."Process start datetime", ErrorMessageText, pagMTNA_IF_StandardCostErr.Caption, pagMTNA_IF_StandardCostErr.ObjectId(false), RecRef) then begin
                        end;
                        ErrorRecCount += 1;
                    end;
                    RecMTNA_IF_StandardCost."Processed datetime" := CurrentDateTime;
                    RecMTNA_IF_StandardCost.Modify();
                end;
                if ((MaxProcCount > 0) and (MaxProcCount <= proccessedCount)) then begin
                    break;
                end;
            until RecMTNA_IF_StandardCost.Next() = 0;
        end;
    end;

    [TryFunction]
    local procedure InsertStandardCostWorksheet(RecMTNA_IF_StandardCost: Record "MTNA_IF_StandardCost"; var RecStandardCostWorksheet: Record "Standard Cost Worksheet")
    var
        errorMsg: Text;
    begin
        RecStandardCostWorksheet.Reset();
        RecStandardCostWorksheet.SetRange("Standard Cost Worksheet Name", RecMTNA_IF_StandardCost."Standard Cost Worksheet Name");
        RecStandardCostWorksheet.SetRange(Type, RecStandardCostWorksheet.Type::Item);
        RecStandardCostWorksheet.SetRange("No.", RecMTNA_IF_StandardCost."No.");
        if RecStandardCostWorksheet.FindFirst() then begin
            /*RecStandardCostWorksheet."New Standard Cost" := RecMTNA_IF_StandardCost."New Standard Cost";
            RecStandardCostWorksheet.Modify(true);*/
            errorMsg := StrSubstNo('The record in table Standard Cost Worksheet already exists. Identification fields and values: Standard Cost Worksheet Name=''%1'',Type=''Item'',No.=''%2''',
                RecMTNA_IF_StandardCost."Standard Cost Worksheet Name", RecMTNA_IF_StandardCost."No.");
            Error(errorMsg);
        end
        else begin
            RecStandardCostWorksheet.Reset();
            RecStandardCostWorksheet.Init();
            /*The following steps can't be changed in order to insert and post the Item Journal Line successfully*/
            RecStandardCostWorksheet.Validate("Standard Cost Worksheet Name", RecMTNA_IF_StandardCost."Standard Cost Worksheet Name");
            RecStandardCostWorksheet.Validate(Type, RecStandardCostWorksheet.Type::Item);
            RecStandardCostWorksheet.Validate("No.", RecMTNA_IF_StandardCost."No.");
            RecStandardCostWorksheet."New Standard Cost" := RecMTNA_IF_StandardCost."New Standard Cost";
            /*The steps above can't be changed in order to insert and post the Item Journal Line successfully*/
            RecStandardCostWorksheet.Insert(true);
        end;
    end;
}

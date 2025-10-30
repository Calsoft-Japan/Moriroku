page 50011 MTNA_IF_StandardCost
{
    //CS 2024/9/5 Channing.Zhou FDD306 Page for MTNA IF Standard Cost
    //CS 2025/10/16 Channing.Zhou FDD300 V7.0 The page will only shows the Ready records and add delete button to the page.
    ApplicationArea = All;
    Caption = 'MTNA IF Standard Cost';
    PageType = List;
    SourceTable = MTNA_IF_StandardCost;
    SourceTableView = where("Status" = const("MTNA IF Status"::Ready));
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Plant; Rec.Plant)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Standard Cost Worksheet Name"; Rec."Standard Cost Worksheet Name")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("New Standard Cost"; Rec."New Standard Cost")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Created datetime"; Rec."Created datetime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Processed datetime"; Rec."Processed datetime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Process start datetime"; Rec."Process start datetime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Error message"; Errormessage)
                {
                    ApplicationArea = All;
                    //ExtendedDataType = RichContent;
                    //MultiLine = true;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Delete Process"; Delete)
                {
                }

                actionref("Rerun Process"; Rerun)
                {
                }
            }
        }
        area(Processing)
        {
            action("Delete")
            {
                ApplicationArea = All;
                Image = Delete;

                trigger OnAction()
                var
                    RecSelectedStandardCost: Record "MTNA_IF_StandardCost";
                begin
                    RecSelectedStandardCost.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                    if (RecSelectedStandardCost.IsEmpty() = false) And (RecSelectedStandardCost.FindFirst()) then begin
                        RecSelectedStandardCost.SetFilter(Status, '<> %1', RecSelectedStandardCost.Status::Ready);
                        if (RecSelectedStandardCost.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedStandardCost.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedStandardCost.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                            if RecSelectedStandardCost.FindFirst() then begin
                                RecSelectedStandardCost.DeleteAll();
                                Message('Deleted successfuly.');
                            end;
                        end;
                    end;
                end;
            }

            action("Rerun")
            {
                ApplicationArea = All;
                Image = Process;
                ToolTip = 'Keeping temporary for unit testing';
                trigger OnAction()
                var
                    RecSelectedStandardCost: Record "MTNA_IF_StandardCost";
                    CuMTNAIFStandardCostProcess: Codeunit "MTNAIFStandardCostProcess";
                    ErrorRecCount: Integer;
                    RecMTNAIFConfiguration: record "MTNA IF Configuration";
                    MaxProcCount: Integer;
                begin
                    MaxProcCount := 0;
                    RecMTNAIFConfiguration.Reset();
                    RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Standard cost");
                    if RecMTNAIFConfiguration.FindFirst() then begin
                        MaxProcCount := RecMTNAIFConfiguration."Max. records to process";
                    end;
                    RecSelectedStandardCost.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                    if (RecSelectedStandardCost.IsEmpty() = false) And (RecSelectedStandardCost.FindFirst()) then begin
                        RecSelectedStandardCost.SetFilter(Status, '<> %1', RecSelectedStandardCost.Status::Ready);
                        if (RecSelectedStandardCost.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedStandardCost.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the interface program?') = true then begin
                            RecSelectedStandardCost.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                            if RecSelectedStandardCost.FindFirst() then begin
                                if CuMTNAIFStandardCostProcess.ProcessStandardCostData(RecSelectedStandardCost, MaxProcCount, ErrorRecCount) then begin
                                    if ErrorRecCount = 0 then begin
                                        Message('All selected records were re-processed.');
                                    end
                                    else begin
                                        Message('Selected records were re-processed with ' + Format(ErrorRecCount) + ' error(s).');
                                    end;
                                end
                                else begin
                                    Message('Selected records were re-processed with error(s).');
                                end;
                            end;
                        end;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        inStream: InStream;
    begin
        Errormessage := Rec.GetErrormessage();
    end;

    var
        Errormessage: Text;
}

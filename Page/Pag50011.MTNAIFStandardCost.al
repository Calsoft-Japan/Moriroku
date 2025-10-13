page 50011 MTNA_IF_StandardCost
{
    //CS 2024/9/5 Channing.Zhou FDD306 Page for MTNA IF Standard Cost
    ApplicationArea = All;
    Caption = 'MTNA IF Standard Cost';
    PageType = List;
    SourceTable = MTNA_IF_StandardCost;
    SourceTableView = where("Status" = const("MTNA IF Status"::Ready));
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;

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
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("New Standard Cost"; Rec."New Standard Cost")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
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
                actionref("Copy Records"; Copy)
                {
                }
                actionref("Change Records Status"; "Change Status")
                {
                }
                actionref("Rerun Process"; Rerun)
                {
                }
            }
        }
        area(Processing)
        {
            action(Copy)
            {
                ApplicationArea = All;
                Image = CopyDocument;
                trigger OnAction()
                var
                    RecSelectedStandardCost: Record "MTNA_IF_StandardCost";
                    RecMTNAIFStandardCost: Record "MTNA_IF_StandardCost";
                    "Last Entry No.": Integer;
                begin
                    RecSelectedStandardCost.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                    if (RecSelectedStandardCost.IsEmpty() = false) And (RecSelectedStandardCost.FindFirst()) then begin
                        repeat
                            RecMTNAIFStandardCost.Reset();
                            if RecMTNAIFStandardCost.FindLast() then begin
                                "Last Entry No." := RecMTNAIFStandardCost."Entry No.";
                                "Last Entry No." += 1;
                                RecMTNAIFStandardCost.Init();
                                RecMTNAIFStandardCost := RecSelectedStandardCost;
                                RecMTNAIFStandardCost."Entry No." := "Last Entry No.";
                                RecMTNAIFStandardCost.Status := RecMTNAIFStandardCost.Status::New;
                                RecMTNAIFStandardCost."Created datetime" := CurrentDateTime;
                                RecMTNAIFStandardCost."Process start datetime" := 0DT;
                                RecMTNAIFStandardCost."Processed datetime" := 0DT;
                                RecMTNAIFStandardCost.SetErrormessage('');
                                RecMTNAIFStandardCost.Insert(true);
                            end;
                        until RecSelectedStandardCost.Next() = 0;
                    end;
                end;
            }
            action("Change status")
            {
                ApplicationArea = All;
                Image = ChangeStatus;
                trigger OnAction()
                var
                    RecSelectedStandardCost: Record "MTNA_IF_StandardCost";
                begin
                    RecSelectedStandardCost.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                    if (RecSelectedStandardCost.IsEmpty() = false) And (RecSelectedStandardCost.FindFirst()) then begin
                        RecSelectedStandardCost.SetFilter(Status, '<> %1', RecSelectedStandardCost.Status::New);
                        if (RecSelectedStandardCost.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedStandardCost.Status::New) + ''' Status.');
                            exit;
                        end
                        else if Confirm('Change status to ''' + Format(RecSelectedStandardCost.Status::Ready) + '''?') = true then begin
                            RecSelectedStandardCost.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                            if RecSelectedStandardCost.FindFirst() then begin
                                repeat
                                    RecSelectedStandardCost.Status := RecSelectedStandardCost.Status::Ready;
                                    RecSelectedStandardCost.Modify(true);
                                until RecSelectedStandardCost.Next() = 0;
                            end;
                        end;
                    end;
                end;
            }

            action("Rerun")
            {
                ApplicationArea = All;
                Image = Process;
                trigger OnAction()
                var
                    RecSelectedStandardCost: Record "MTNA_IF_StandardCost";
                    CuMTNAIFStandardCostProcess: Codeunit "MTNAIFStandardCostProcess";
                    ErrorRecCount: Integer;
                begin
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
                                if CuMTNAIFStandardCostProcess.ProcessStandardCostData(RecSelectedStandardCost, ErrorRecCount) then begin
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

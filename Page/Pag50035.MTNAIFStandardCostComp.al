page 50035 MTNA_IF_StandardCostComp
{
    //CS 2025/10/16 Channing.Zhou FDD306 Page for MTNA IF Standard Cost Completed
    ApplicationArea = All;
    Caption = 'MTNA IF Standard Cost Completed';
    PageType = List;
    SourceTable = MTNA_IF_StandardCost;
    SourceTableView = where("Status" = const("MTNA IF Status"::Completed));
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

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
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("New Standard Cost"; Rec."New Standard Cost")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                actionref("Archive Process"; Archive)
                {
                }
            }
        }
        area(Processing)
        {
            action(Archive)
            {
                ApplicationArea = All;
                Image = Archive;
                ToolTip = 'Adding temporary for unit testing';

                trigger OnAction()
                var
                    RecSelectedStandardCost: Record "MTNA_IF_StandardCost";
                    CuMTNAIFStandardCostProcArc: Codeunit "MTNAIFStandardCostProcArc";
                    ErrorRecCount: Integer;
                begin
                    RecSelectedStandardCost.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                    if (RecSelectedStandardCost.IsEmpty() = false) And (RecSelectedStandardCost.FindFirst()) then begin
                        RecSelectedStandardCost.SetFilter(Status, '<> %1', RecSelectedStandardCost.Status::Completed);
                        if (RecSelectedStandardCost.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedStandardCost.Status::Completed) + ''' status.');
                            exit;
                        end
                        else if Confirm('Move the selected records to Archive?') = true then begin
                            RecSelectedStandardCost.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                            if RecSelectedStandardCost.FindFirst() then begin
                                if CuMTNAIFStandardCostProcArc.ProcArcStandardCostData(RecSelectedStandardCost, ErrorRecCount) then begin
                                    if ErrorRecCount = 0 then begin
                                        Message('All selected records were moved to Archive.');
                                    end
                                    else begin
                                        Message('Selected records were moved to Archive with ' + Format(ErrorRecCount) + ' error(s).');
                                    end;
                                end
                                else begin
                                    Message('Selected records were moved to Archive with error(s).');
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

page 50034 MTNA_IF_StandardCostErr
{
    //CS 2025/10/16 Channing.Zhou FDD306 Page for MTNA IF Standard Cost Error
    ApplicationArea = All;
    Caption = 'MTNA IF Standard Cost Error';
    PageType = List;
    SourceTable = MTNA_IF_StandardCost;
    SourceTableView = where("Status" = const("MTNA IF Status"::Error));
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
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("New Standard Cost"; Rec."New Standard Cost")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
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
                        RecSelectedStandardCost.SetFilter(Status, '<> %1', RecSelectedStandardCost.Status::Error);
                        if (RecSelectedStandardCost.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedStandardCost.Status::Error) + ''' status.');
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

                trigger OnAction()
                var
                    RecSelectedStandardCost: Record "MTNA_IF_StandardCost";
                begin
                    RecSelectedStandardCost.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                    if (RecSelectedStandardCost.IsEmpty() = false) And (RecSelectedStandardCost.FindFirst()) then begin
                        RecSelectedStandardCost.SetFilter(Status, '<> %1', RecSelectedStandardCost.Status::Error);
                        if (RecSelectedStandardCost.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedStandardCost.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the selected records?') = true then begin
                            RecSelectedStandardCost.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedStandardCost);
                            if RecSelectedStandardCost.FindFirst() then begin
                                repeat
                                    RecSelectedStandardCost.Status := RecSelectedStandardCost.Status::Ready;
                                    RecSelectedStandardCost."Process start datetime" := 0DT;
                                    RecSelectedStandardCost."Processed datetime" := 0DT;
                                    RecSelectedStandardCost.SetErrormessage('');
                                    RecSelectedStandardCost.Modify();
                                until RecSelectedStandardCost.Next() = 0;
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

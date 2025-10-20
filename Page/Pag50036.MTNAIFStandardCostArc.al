page 50036 MTNA_IF_StandardCostArc
{
    //CS 2025/10/16 Channing.Zhou FDD306 Page for MTNA IF Standard Cost Archive
    ApplicationArea = All;
    Caption = 'MTNA IF Standard Cost Archive';
    PageType = List;
    SourceTable = MTNA_IF_StandardCostArchive;
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

                actionref("Delete Process"; Delete)
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
                    RecSelectedStandardCostArchive: Record "MTNA_IF_StandardCostArchive";
                begin
                    RecSelectedStandardCostArchive.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedStandardCostArchive);
                    if (RecSelectedStandardCostArchive.IsEmpty() = false) And (RecSelectedStandardCostArchive.FindFirst()) then begin
                        RecSelectedStandardCostArchive.SetFilter(Status, '<> %1', RecSelectedStandardCostArchive.Status::Completed);
                        if (RecSelectedStandardCostArchive.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedStandardCostArchive.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedStandardCostArchive.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedStandardCostArchive);
                            if RecSelectedStandardCostArchive.FindFirst() then begin
                                RecSelectedStandardCostArchive.DeleteAll();
                                Message('Deleted successfuly.');
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

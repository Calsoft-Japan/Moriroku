page 50021 MTNA_IF_OutputJournalArc
{
    //CS 2025/10/10 Channing.Zhou FDD301 Page for MTNA IF Output Journal Archive
    ApplicationArea = All;
    Caption = 'MTNA IF Output Journal Archive';
    PageType = List;
    SourceTable = MTNA_IF_OutputJournalArchive;
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
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Primary record ID"; Rec."Primary record ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Machine Center Code"; Rec."Machine Center Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Output Quantity"; Rec."Output Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Work Shift Code"; Rec."Work Shift Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Scrap Quantity"; Rec."Scrap Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Scrap Code"; Rec."Scrap Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Setup Time"; Rec."Setup Time")
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
                    RecSelectedOutputJournalArchive: Record "MTNA_IF_OutputJournalArchive";
                begin
                    RecSelectedOutputJournalArchive.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedOutputJournalArchive);
                    if (RecSelectedOutputJournalArchive.IsEmpty() = false) And (RecSelectedOutputJournalArchive.FindFirst()) then begin
                        RecSelectedOutputJournalArchive.SetFilter(Status, '<> %1', RecSelectedOutputJournalArchive.Status::Completed);
                        if (RecSelectedOutputJournalArchive.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedOutputJournalArchive.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedOutputJournalArchive.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedOutputJournalArchive);
                            if RecSelectedOutputJournalArchive.FindFirst() then begin
                                RecSelectedOutputJournalArchive.DeleteAll();
                                Message('Deleted successfuly.');
                            end;
                        end;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Errormessage := Rec.GetErrormessage();
    end;

    var
        Errormessage: Text;
}

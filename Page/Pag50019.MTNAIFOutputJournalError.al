page 50019 MTNA_IF_OutputJournalErr
{
    //CS 2025/10/10 Channing.Zhou FDD301 Page for MTNA IF Output Journal Error
    ApplicationArea = All;
    Caption = 'MTNA IF Output Journal Error';
    PageType = List;
    SourceTable = MTNA_IF_OutputJournal;
    SourceTableView = where("Status" = const("MTNA IF Status"::Error));
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
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Primary record ID"; Rec."Primary record ID")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Machine Center Code"; Rec."Machine Center Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Output Quantity"; Rec."Output Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Work Shift Code"; Rec."Work Shift Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Scrap Quantity"; Rec."Scrap Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Scrap Code"; Rec."Scrap Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Setup Time"; Rec."Setup Time")
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
                actionref("Rerun Process"; Rerun)
                {
                }
            }
        }
        area(Processing)
        {
            action("Rerun")
            {
                ApplicationArea = All;
                Image = Process;
                //Enabled = ReRunEnabled; //Control the button enabled by the selected records' status column
                trigger OnAction()
                var
                    RecSelectedOutputJournal: Record "MTNA_IF_OutputJournal";
                    CuMTNAIFOutputJournalProcess: Codeunit "MTNAIFOutputJournalProcess";
                    ErrorRecCount: Integer;
                begin
                    RecSelectedOutputJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedOutputJournal);
                    if (RecSelectedOutputJournal.IsEmpty() = false) And (RecSelectedOutputJournal.FindFirst()) then begin
                        RecSelectedOutputJournal.SetFilter(Status, '<> %1', RecSelectedOutputJournal.Status::Error);
                        if (RecSelectedOutputJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedOutputJournal.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the selected records?') = true then begin
                            RecSelectedOutputJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedOutputJournal);
                            if RecSelectedOutputJournal.FindFirst() then begin
                                repeat
                                    RecSelectedOutputJournal.Status := RecSelectedOutputJournal.Status::Ready;
                                    RecSelectedOutputJournal."Process start datetime" := 0DT;
                                    RecSelectedOutputJournal."Processed datetime" := 0DT;
                                    RecSelectedOutputJournal.SetErrormessage('');
                                    RecSelectedOutputJournal.Modify();
                                until RecSelectedOutputJournal.Next() = 0;
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

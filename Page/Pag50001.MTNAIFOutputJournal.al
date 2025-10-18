page 50001 MTNA_IF_OutputJournal
{
    //CS 2024/8/13 Channing.Zhou FDD301 Page for MTNA IF Output Journal
    //CS 2025/10/10 Channing.Zhou FDD300 V7.0 The page will only shows the Ready records and add delete button to the page.
    ApplicationArea = All;
    Caption = 'MTNA IF Output Journal';
    PageType = List;
    SourceTable = MTNA_IF_OutputJournal;
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
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Primary record ID"; Rec."Primary record ID")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Machine Center Code"; Rec."Machine Center Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Output Quantity"; Rec."Output Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Work Shift Code"; Rec."Work Shift Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Scrap Quantity"; Rec."Scrap Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Scrap Code"; Rec."Scrap Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Setup Time"; Rec."Setup Time")
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
                    RecSelectedOutputJournal: Record "MTNA_IF_OutputJournal";
                    ErrorRecCount: Integer;
                begin
                    RecSelectedOutputJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedOutputJournal);
                    if (RecSelectedOutputJournal.IsEmpty() = false) And (RecSelectedOutputJournal.FindFirst()) then begin
                        RecSelectedOutputJournal.SetFilter(Status, '<> %1', RecSelectedOutputJournal.Status::Ready);
                        if (RecSelectedOutputJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedOutputJournal.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedOutputJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedOutputJournal);
                            if RecSelectedOutputJournal.FindFirst() then begin
                                RecSelectedOutputJournal.DeleteAll();
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
                        RecSelectedOutputJournal.SetFilter(Status, '<> %1', RecSelectedOutputJournal.Status::Ready);
                        if (RecSelectedOutputJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedOutputJournal.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the interface program?') = true then begin
                            RecSelectedOutputJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedOutputJournal);
                            if RecSelectedOutputJournal.FindFirst() then begin
                                if CuMTNAIFOutputJournalProcess.ProcessOutputJournalData(RecSelectedOutputJournal, ErrorRecCount) then begin
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
    begin
        Errormessage := Rec.GetErrormessage();
    end;

    var
        Errormessage: Text;
}

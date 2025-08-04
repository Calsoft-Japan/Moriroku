page 50001 MTNA_IF_OutputJournal
{
    //CS 2024/8/13 Channing.Zhou FDD301 Page for MTNA IF Output Journal
    ApplicationArea = All;
    Caption = 'MTNA IF Output Journal';
    PageType = List;
    SourceTable = MTNA_IF_OutputJournal;
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
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Primary record ID"; Rec."Primary record ID")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Machine Center Code"; Rec."Machine Center Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Output Quantity"; Rec."Output Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Work Shift Code"; Rec."Work Shift Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Scrap Quantity"; Rec."Scrap Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Scrap Code"; Rec."Scrap Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Setup Time"; Rec."Setup Time")
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
                //Enabled = CopyEnabled; //Control the button enabled by the selected records' status column
                trigger OnAction()
                var
                    RecSelectedOutputJournal: Record "MTNA_IF_OutputJournal";
                    RecMTNAIFOutputJournal: Record "MTNA_IF_OutputJournal";
                    "Last Entry No.": Integer;
                begin
                    RecSelectedOutputJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedOutputJournal);
                    if (RecSelectedOutputJournal.IsEmpty() = false) And (RecSelectedOutputJournal.FindFirst()) then begin
                        repeat
                            RecMTNAIFOutputJournal.Reset();
                            if RecMTNAIFOutputJournal.FindLast() then begin
                                "Last Entry No." := RecMTNAIFOutputJournal."Entry No.";
                                "Last Entry No." += 1;
                                RecMTNAIFOutputJournal.Init();
                                RecMTNAIFOutputJournal := RecSelectedOutputJournal;
                                RecMTNAIFOutputJournal."Entry No." := "Last Entry No.";
                                RecMTNAIFOutputJournal.Status := RecMTNAIFOutputJournal.Status::New;
                                RecMTNAIFOutputJournal."Created datetime" := CurrentDateTime;
                                RecMTNAIFOutputJournal."Process start datetime" := 0DT;
                                RecMTNAIFOutputJournal."Processed datetime" := 0DT;
                                RecMTNAIFOutputJournal.SetErrormessage('');
                                RecMTNAIFOutputJournal.Insert(true);
                            end;
                        until RecSelectedOutputJournal.Next() = 0;
                    end;
                end;
            }
            action("Change status")
            {
                ApplicationArea = All;
                Image = ChangeStatus;
                //Enabled = ChangeStatusEnabled; //Control the button enabled by the selected records' status column
                trigger OnAction()
                var
                    RecSelectedOutputJournal: Record "MTNA_IF_OutputJournal";
                begin
                    RecSelectedOutputJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedOutputJournal);
                    if (RecSelectedOutputJournal.IsEmpty() = false) And (RecSelectedOutputJournal.FindFirst()) then begin
                        RecSelectedOutputJournal.SetFilter(Status, '<> %1', RecSelectedOutputJournal.Status::New);
                        if (RecSelectedOutputJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedOutputJournal.Status::New) + ''' Status.');
                            exit;
                        end
                        else if Confirm('Change status to ''' + Format(RecSelectedOutputJournal.Status::Ready) + '''?') = true then begin
                            RecSelectedOutputJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedOutputJournal);
                            if RecSelectedOutputJournal.FindFirst() then begin
                                repeat
                                    RecSelectedOutputJournal.Status := RecSelectedOutputJournal.Status::Ready;
                                    RecSelectedOutputJournal.Modify(true);
                                until RecSelectedOutputJournal.Next() = 0;
                            end;
                        end;
                    end;
                end;
            }

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

    /*
    //Control the button enabled by the selected records' status column
    trigger OnOpenPage()
    begin
        PageOpening := true;
        CopyEnabled := false;
        ChangeStatusEnabled := false;
        ReRunEnabled := false;
    end;

    trigger OnAfterGetCurrRecord()
    var
        RecSelectedOutputJournal: Record "MTNA_IF_OutputJournal";
    begin
        if not PageOpening then begin
            RecSelectedOutputJournal.Reset();
            CurrPage.SetSelectionFilter(RecSelectedOutputJournal);
            if (RecSelectedOutputJournal.IsEmpty() = false) And (RecSelectedOutputJournal.FindFirst()) then begin
                CopyEnabled := true;
                RecSelectedOutputJournal.SetFilter(Status, '<> %1', RecSelectedOutputJournal.Status::New);
                if (RecSelectedOutputJournal.FindFirst()) then begin
                    ChangeStatusEnabled := false;
                end
                else begin
                    ChangeStatusEnabled := true;
                end;
                RecSelectedOutputJournal.Reset();
                CurrPage.SetSelectionFilter(RecSelectedOutputJournal);
                RecSelectedOutputJournal.SetFilter(Status, '<> %1', RecSelectedOutputJournal.Status::Ready);
                if (RecSelectedOutputJournal.FindFirst()) then begin
                    ReRunEnabled := false;
                end
                else begin
                    ReRunEnabled := true;
                end;
            end
            else begin
                CopyEnabled := false;
            end;
        end;
    end;*/

    trigger OnAfterGetRecord()
    begin
        Errormessage := Rec.GetErrormessage();
        //PageOpening := false; //Control the button enabled by the selected records' status column
    end;

    var
        Errormessage: Text;
    /*
    //Control the button enabled by the selected records' status column
    PageOpening: Boolean;
    CopyEnabled: Boolean;
    ChangeStatusEnabled: Boolean;
    ReRunEnabled: Boolean;*/
}

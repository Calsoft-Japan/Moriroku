page 50013 MTNA_IF_ItemJournal
{
    //CS 2024/9/5 Channing.Zhou FDD307 Page for MTNA IF Item Journal
    ApplicationArea = All;
    Caption = 'MTNA IF Item Journal';
    PageType = List;
    SourceTable = MTNA_IF_ItemJournal;
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
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Document No."; Rec."Document No.")
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
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Gen Bus Posting Group"; Rec."Gen Bus Posting Group")
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
                    RecSelectedItemJournal: Record "MTNA_IF_ItemJournal";
                    RecMTNAIFItemJournal: Record "MTNA_IF_ItemJournal";
                    "Last Entry No.": Integer;
                begin
                    RecSelectedItemJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemJournal);
                    if (RecSelectedItemJournal.IsEmpty() = false) And (RecSelectedItemJournal.FindFirst()) then begin
                        repeat
                            RecMTNAIFItemJournal.Reset();
                            if RecMTNAIFItemJournal.FindLast() then begin
                                "Last Entry No." := RecMTNAIFItemJournal."Entry No.";
                                "Last Entry No." += 1;
                                RecMTNAIFItemJournal.Init();
                                RecMTNAIFItemJournal := RecSelectedItemJournal;
                                RecMTNAIFItemJournal."Entry No." := "Last Entry No.";
                                RecMTNAIFItemJournal.Status := RecMTNAIFItemJournal.Status::New;
                                RecMTNAIFItemJournal."Created datetime" := CurrentDateTime;
                                RecMTNAIFItemJournal."Process start datetime" := 0DT;
                                RecMTNAIFItemJournal."Processed datetime" := 0DT;
                                RecMTNAIFItemJournal.SetErrormessage('');
                                RecMTNAIFItemJournal.Insert(true);
                            end;
                        until RecSelectedItemJournal.Next() = 0;
                    end;
                end;
            }
            action("Change status")
            {
                ApplicationArea = All;
                Image = ChangeStatus;
                trigger OnAction()
                var
                    RecSelectedItemJournal: Record "MTNA_IF_ItemJournal";
                begin
                    RecSelectedItemJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemJournal);
                    if (RecSelectedItemJournal.IsEmpty() = false) And (RecSelectedItemJournal.FindFirst()) then begin
                        RecSelectedItemJournal.SetFilter(Status, '<> %1', RecSelectedItemJournal.Status::New);
                        if (RecSelectedItemJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedItemJournal.Status::New) + ''' Status.');
                            exit;
                        end
                        else if Confirm('Change status to ''' + Format(RecSelectedItemJournal.Status::Ready) + '''?') = true then begin
                            RecSelectedItemJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedItemJournal);
                            if RecSelectedItemJournal.FindFirst() then begin
                                repeat
                                    RecSelectedItemJournal.Status := RecSelectedItemJournal.Status::Ready;
                                    RecSelectedItemJournal.Modify(true);
                                until RecSelectedItemJournal.Next() = 0;
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
                    RecSelectedItemJournal: Record "MTNA_IF_ItemJournal";
                    CuMTNAIFItemJournalProcess: Codeunit "MTNAIFItemJournalProcess";
                    ErrorRecCount: Integer;
                begin
                    RecSelectedItemJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemJournal);
                    if (RecSelectedItemJournal.IsEmpty() = false) And (RecSelectedItemJournal.FindFirst()) then begin
                        RecSelectedItemJournal.SetFilter(Status, '<> %1', RecSelectedItemJournal.Status::Ready);
                        if (RecSelectedItemJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedItemJournal.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the interface program?') = true then begin
                            RecSelectedItemJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedItemJournal);
                            if RecSelectedItemJournal.FindFirst() then begin
                                if CuMTNAIFItemJournalProcess.ProcessItemJournalData(RecSelectedItemJournal, ErrorRecCount) then begin
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

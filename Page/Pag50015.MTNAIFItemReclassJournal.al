page 50015 MTNA_IF_ItemReclassJournal
{
    //CS 2024/9/5 Channing.Zhou FDD309 Page for MTNA IF Item Reclass Journal
    ApplicationArea = All;
    Caption = 'MTNA IF Item Reclass Journal';
    PageType = List;
    SourceTable = MTNA_IF_ItemReclassJournal;
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
                field("New Location Code"; Rec."New Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("New Bin Code"; Rec."New Bin Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Quantity"; Rec."Quantity")
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
                    RecSelectedItemReclassJournal: Record "MTNA_IF_ItemReclassJournal";
                    RecMTNAIFItemReclassJournal: Record "MTNA_IF_ItemReclassJournal";
                    "Last Entry No.": Integer;
                begin
                    RecSelectedItemReclassJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                    if (RecSelectedItemReclassJournal.IsEmpty() = false) And (RecSelectedItemReclassJournal.FindFirst()) then begin
                        repeat
                            RecMTNAIFItemReclassJournal.Reset();
                            if RecMTNAIFItemReclassJournal.FindLast() then begin
                                "Last Entry No." := RecMTNAIFItemReclassJournal."Entry No.";
                                "Last Entry No." += 1;
                                RecMTNAIFItemReclassJournal.Init();
                                RecMTNAIFItemReclassJournal := RecSelectedItemReclassJournal;
                                RecMTNAIFItemReclassJournal."Entry No." := "Last Entry No.";
                                RecMTNAIFItemReclassJournal.Status := RecMTNAIFItemReclassJournal.Status::New;
                                RecMTNAIFItemReclassJournal."Created datetime" := CurrentDateTime;
                                RecMTNAIFItemReclassJournal."Process start datetime" := 0DT;
                                RecMTNAIFItemReclassJournal."Processed datetime" := 0DT;
                                RecMTNAIFItemReclassJournal.SetErrormessage('');
                                RecMTNAIFItemReclassJournal.Insert(true);
                            end;
                        until RecSelectedItemReclassJournal.Next() = 0;
                    end;
                end;
            }
            action("Change status")
            {
                ApplicationArea = All;
                Image = ChangeStatus;
                trigger OnAction()
                var
                    RecSelectedItemReclassJournal: Record "MTNA_IF_ItemReclassJournal";
                begin
                    RecSelectedItemReclassJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                    if (RecSelectedItemReclassJournal.IsEmpty() = false) And (RecSelectedItemReclassJournal.FindFirst()) then begin
                        RecSelectedItemReclassJournal.SetFilter(Status, '<> %1', RecSelectedItemReclassJournal.Status::New);
                        if (RecSelectedItemReclassJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedItemReclassJournal.Status::New) + ''' Status.');
                            exit;
                        end
                        else if Confirm('Change status to ''' + Format(RecSelectedItemReclassJournal.Status::Ready) + '''?') = true then begin
                            RecSelectedItemReclassJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                            if RecSelectedItemReclassJournal.FindFirst() then begin
                                repeat
                                    RecSelectedItemReclassJournal.Status := RecSelectedItemReclassJournal.Status::Ready;
                                    RecSelectedItemReclassJournal.Modify(true);
                                until RecSelectedItemReclassJournal.Next() = 0;
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
                    RecSelectedItemReclassJournal: Record "MTNA_IF_ItemReclassJournal";
                    CuMTNAIFItemJournalProcess: Codeunit "MTNAIFItemReclasJournalProcess";
                    ErrorRecCount: Integer;
                begin
                    RecSelectedItemReclassJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                    if (RecSelectedItemReclassJournal.IsEmpty() = false) And (RecSelectedItemReclassJournal.FindFirst()) then begin
                        RecSelectedItemReclassJournal.SetFilter(Status, '<> %1', RecSelectedItemReclassJournal.Status::Ready);
                        if (RecSelectedItemReclassJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedItemReclassJournal.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the interface program?') = true then begin
                            RecSelectedItemReclassJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                            if RecSelectedItemReclassJournal.FindFirst() then begin
                                if CuMTNAIFItemJournalProcess.ProcessItemReclassJournalData(RecSelectedItemReclassJournal, ErrorRecCount) then begin
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

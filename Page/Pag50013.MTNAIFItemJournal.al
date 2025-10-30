page 50013 MTNA_IF_ItemJournal
{
    //CS 2024/9/5 Channing.Zhou FDD307 Page for MTNA IF Item Journal
    //CS 2025/10/17 Channing.Zhou FDD300 V7.0 The page will only shows the Ready records and add delete button to the page.
    ApplicationArea = All;
    Caption = 'MTNA IF Item Journal';
    PageType = List;
    SourceTable = MTNA_IF_ItemJournal;
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
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Document No."; Rec."Document No.")
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
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Gen Bus Posting Group"; Rec."Gen Bus Posting Group")
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
                    RecSelectedItemJournal: Record "MTNA_IF_ItemJournal";
                begin
                    RecSelectedItemJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemJournal);
                    if (RecSelectedItemJournal.IsEmpty() = false) And (RecSelectedItemJournal.FindFirst()) then begin
                        RecSelectedItemJournal.SetFilter(Status, '<> %1', RecSelectedItemJournal.Status::Ready);
                        if (RecSelectedItemJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedItemJournal.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedItemJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedItemJournal);
                            if RecSelectedItemJournal.FindFirst() then begin
                                RecSelectedItemJournal.DeleteAll();
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
                    RecSelectedItemJournal: Record "MTNA_IF_ItemJournal";
                    CuMTNAIFItemJournalProcess: Codeunit "MTNAIFItemJournalProcess";
                    ErrorRecCount: Integer;
                    RecMTNAIFConfiguration: record "MTNA IF Configuration";
                    MaxProcCount: Integer;
                begin
                    MaxProcCount := 0;
                    RecMTNAIFConfiguration.Reset();
                    RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Item journal");
                    if RecMTNAIFConfiguration.FindFirst() then begin
                        MaxProcCount := RecMTNAIFConfiguration."Max. records to process";
                    end;
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
                                if CuMTNAIFItemJournalProcess.ProcessItemJournalData(RecSelectedItemJournal, MaxProcCount, ErrorRecCount) then begin
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

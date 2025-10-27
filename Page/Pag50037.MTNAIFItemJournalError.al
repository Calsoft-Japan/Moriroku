page 50037 MTNA_IF_ItemJournalErr
{
    //CS 2025/10/17 Channing.Zhou FDD307 Page for MTNA IF Item Journal Error
    ApplicationArea = All;
    Caption = 'MTNA IF Item Journal Error';
    PageType = List;
    SourceTable = MTNA_IF_ItemJournal;
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
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Document No."; Rec."Document No.")
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
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Gen Bus Posting Group"; Rec."Gen Bus Posting Group")
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
                    RecSelectedItemJournal: Record "MTNA_IF_ItemJournal";
                begin
                    RecSelectedItemJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemJournal);
                    if (RecSelectedItemJournal.IsEmpty() = false) And (RecSelectedItemJournal.FindFirst()) then begin
                        RecSelectedItemJournal.SetFilter(Status, '<> %1', RecSelectedItemJournal.Status::Error);
                        if (RecSelectedItemJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedItemJournal.Status::Error) + ''' status.');
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
                begin
                    RecSelectedItemJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemJournal);
                    if (RecSelectedItemJournal.IsEmpty() = false) And (RecSelectedItemJournal.FindFirst()) then begin
                        RecSelectedItemJournal.SetFilter(Status, '<> %1', RecSelectedItemJournal.Status::Error);
                        if (RecSelectedItemJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedItemJournal.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the selected records?') = true then begin
                            RecSelectedItemJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedItemJournal);
                            if RecSelectedItemJournal.FindFirst() then begin
                                repeat
                                    RecSelectedItemJournal.Status := RecSelectedItemJournal.Status::Ready;
                                    RecSelectedItemJournal."Process start datetime" := 0DT;
                                    RecSelectedItemJournal."Processed datetime" := 0DT;
                                    RecSelectedItemJournal.SetErrormessage('');
                                    RecSelectedItemJournal.Modify();
                                until RecSelectedItemJournal.Next() = 0;
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

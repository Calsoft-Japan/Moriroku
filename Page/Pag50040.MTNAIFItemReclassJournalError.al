page 50040 MTNA_IF_ItemReclassJournalErr
{
    //CS 2025/10/20 Channing.Zhou FDD309 Page for MTNA IF Item Reclass Journal Error
    ApplicationArea = All;
    Caption = 'MTNA IF Item Reclass Journal Error';
    PageType = List;
    SourceTable = MTNA_IF_ItemReclassJournal;
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
                field("New Location Code"; Rec."New Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("New Bin Code"; Rec."New Bin Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Quantity"; Rec."Quantity")
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
                    RecSelectedItemReclassJournal: Record "MTNA_IF_ItemReclassJournal";
                begin
                    RecSelectedItemReclassJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                    if (RecSelectedItemReclassJournal.IsEmpty() = false) And (RecSelectedItemReclassJournal.FindFirst()) then begin
                        RecSelectedItemReclassJournal.SetFilter(Status, '<> %1', RecSelectedItemReclassJournal.Status::Error);
                        if (RecSelectedItemReclassJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedItemReclassJournal.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedItemReclassJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                            if RecSelectedItemReclassJournal.FindFirst() then begin
                                RecSelectedItemReclassJournal.DeleteAll();
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
                    RecSelectedItemReclassJournal: Record "MTNA_IF_ItemReclassJournal";
                begin
                    RecSelectedItemReclassJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                    if (RecSelectedItemReclassJournal.IsEmpty() = false) And (RecSelectedItemReclassJournal.FindFirst()) then begin
                        RecSelectedItemReclassJournal.SetFilter(Status, '<> %1', RecSelectedItemReclassJournal.Status::Error);
                        if (RecSelectedItemReclassJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedItemReclassJournal.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the selected records?') = true then begin
                            RecSelectedItemReclassJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                            if RecSelectedItemReclassJournal.FindFirst() then begin
                                repeat
                                    RecSelectedItemReclassJournal.Status := RecSelectedItemReclassJournal.Status::Ready;
                                    RecSelectedItemReclassJournal."Process start datetime" := 0DT;
                                    RecSelectedItemReclassJournal."Processed datetime" := 0DT;
                                    RecSelectedItemReclassJournal.SetErrormessage('');
                                    RecSelectedItemReclassJournal.Modify();
                                until RecSelectedItemReclassJournal.Next() = 0;
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

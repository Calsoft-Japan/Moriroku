page 50041 MTNA_IF_ItemReclassJournalComp
{
    //CS 2025/10/20 Channing.Zhou FDD309 Page for MTNA IF Item Reclass Journal Completed
    ApplicationArea = All;
    Caption = 'MTNA IF Item Reclass Journal Completed';
    PageType = List;
    SourceTable = MTNA_IF_ItemReclassJournal;
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
                field("Document No."; Rec."Document No.")
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
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("New Location Code"; Rec."New Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("New Bin Code"; Rec."New Bin Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Gen Bus Posting Group"; Rec."Gen Bus Posting Group")
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
                actionref("Archive Process"; Archive)
                {
                }
            }
        }
        area(Processing)
        {
            action(Archive)
            {
                ApplicationArea = All;
                Image = Archive;
                ToolTip = 'Adding temporary for unit testing';

                trigger OnAction()
                var
                    RecSelectedItemReclassJournal: Record "MTNA_IF_ItemReclassJournal";
                    CuMTNAIFItemReclassJournalProcArc: Codeunit "MTNAIFItemReclasJournalProcArc";
                    ErrorRecCount: Integer;
                begin
                    RecSelectedItemReclassJournal.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                    if (RecSelectedItemReclassJournal.IsEmpty() = false) And (RecSelectedItemReclassJournal.FindFirst()) then begin
                        RecSelectedItemReclassJournal.SetFilter(Status, '<> %1', RecSelectedItemReclassJournal.Status::Completed);
                        if (RecSelectedItemReclassJournal.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedItemReclassJournal.Status::Completed) + ''' status.');
                            exit;
                        end
                        else if Confirm('Move the selected records to Archive?') = true then begin
                            RecSelectedItemReclassJournal.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedItemReclassJournal);
                            if RecSelectedItemReclassJournal.FindFirst() then begin
                                if CuMTNAIFItemReclassJournalProcArc.ProcArcItemReclassJournalData(RecSelectedItemReclassJournal, ErrorRecCount) then begin
                                    if ErrorRecCount = 0 then begin
                                        Message('All selected records were moved to Archive.');
                                    end
                                    else begin
                                        Message('Selected records were moved to Archive with ' + Format(ErrorRecCount) + ' error(s).');
                                    end;
                                end
                                else begin
                                    Message('Selected records were moved to Archive with error(s).');
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

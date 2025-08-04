page 50016 MTNA_IF_ItemReclassJournal_API
{
    //CS 2024/9/5 Channing.Zhou FDD309 Page for MTNA IF Item Reclass Journal API
    ApplicationArea = All;
    Caption = 'MTNA IF Item Journal API';
    PageType = API;
    APIPublisher = 'CalsoftSystems';
    APIGroup = 'MTNAIF';
    APIVersion = 'v2.0';
    EntitySetCaption = 'MTNA IF Item Reclass Journals';
    EntitySetName = 'itemReclassJournal';
    EntityCaption = 'MTNA IF Item Reclass Journal';
    EntityName = 'mtnaIFItemReclassJournal';
    ODataKeyFields = "Entry No.";
    SourceTable = MTNA_IF_ItemReclassJournal;
    Extensible = false;
    DelayedInsert = true;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(EntryNo; Rec."Entry No.")
                {
                    Visible = false;
                    Editable = false;
                }
                field(Plant; Rec.Plant)
                {
                    ApplicationArea = All;
                }
                field(JournalBatchName; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field(Postingdate; Rec."Posting date")
                {
                    ApplicationArea = All;
                }
                field(DocumentNo; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field(ItemNo; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(PrimaryrecordID; Rec."Primary record ID")
                {
                    ApplicationArea = All;
                }
                field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(NewLocationCode; Rec."New Location Code")
                {
                    ApplicationArea = All;
                }
                field(BinCode; Rec."Bin Code")
                {
                    ApplicationArea = All;
                }
                field(NewBinCode; Rec."New Bin Code")
                {
                    ApplicationArea = All;
                }
                field(UnitofMeasureCode; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec."Quantity")
                {
                    ApplicationArea = All;
                }
                field(LotNo; Rec."Lot No.")
                {
                    ApplicationArea = All;
                }
                field(GenBusPostingGroup; Rec."Gen Bus Posting Group")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Status := Rec.Status::Ready;
        Rec."Created datetime" := CurrentDateTime;
        Rec.SetErrormessage('');
        if Rec.Insert(true) then begin
            exit(false);
        end
        else begin
            exit(false);
        end;
    end;
}

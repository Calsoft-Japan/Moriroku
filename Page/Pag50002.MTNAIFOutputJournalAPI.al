page 50002 MTNA_IF_OutputJournal_API
{
    //CS 2024/8/13 Channing.Zhou FDD301 Page for MTNA IF Output Journal API
    ApplicationArea = All;
    Caption = 'MTNA IF Output Journal API';
    PageType = API;
    APIPublisher = 'CalsoftSystems';
    APIGroup = 'MTNAIF';
    APIVersion = 'v2.0';
    EntitySetCaption = 'MTNA IF Output Journals';
    EntitySetName = 'outputJournal';
    EntityCaption = 'MTNA IF Output Journal';
    EntityName = 'mtnaIFOutputJournal';
    ODataKeyFields = "Entry No.";
    SourceTable = MTNA_IF_OutputJournal;
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
                field(OrderNo; Rec."Order No.")
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
                field(OperationNo; Rec."Operation No.")
                {
                    ApplicationArea = All;
                }
                field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(BinCode; Rec."Bin Code")
                {
                    ApplicationArea = All;
                }
                field(MachineCenterCode; Rec."Machine Center Code")
                {
                    ApplicationArea = All;
                }
                field(OutputQuantity; Rec."Output Quantity")
                {
                    ApplicationArea = All;
                }
                field(WorkShiftCode; Rec."Work Shift Code")
                {
                    ApplicationArea = All;
                }
                field(ScrapQuantity; Rec."Scrap Quantity")
                {
                    ApplicationArea = All;
                }
                field(ScrapCode; Rec."Scrap Code")
                {
                    ApplicationArea = All;
                }
                field(SetupTime; Rec."Setup Time")
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

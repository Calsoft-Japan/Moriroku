page 50006 MTNA_IF_POLine_API
{
    //CS 2024/8/13 Channing.Zhou FDD302 Page for MTNA IF PO Line API
    ApplicationArea = All;
    Caption = 'MTNA IF PO Line API';
    PageType = API;
    APIPublisher = 'CalsoftSystems';
    APIGroup = 'MTNAIF';
    APIVersion = 'v2.0';
    EntitySetCaption = 'MTNA IF PO Lines';
    EntitySetName = 'purchaseLine';
    EntityCaption = 'MTNA IF PO Line';
    EntityName = 'mtnaIFPOLine';
    ODataKeyFields = "Entry No.";
    SourceTable = MTNA_IF_POLines;
    Extensible = false;
    DelayedInsert = true;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(EntryNo; Rec."Entry No.")
                {
                    Visible = false;
                    Editable = false;
                }
                field(HeaderEntryNo; Rec."Header Entry No.")
                {
                    Visible = false;
                }
                field(Plant; Rec.Plant)
                {
                    ApplicationArea = All;
                }
                field(OrderID; Rec."Order ID")
                {
                    ApplicationArea = All;
                }
                field(LineNo; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec."Description")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec."Quantity")
                {
                    ApplicationArea = All;
                }
                field(UnitPrice; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field(UnitofMeasureCode; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field(LocationCode; Rec."Location Code")
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

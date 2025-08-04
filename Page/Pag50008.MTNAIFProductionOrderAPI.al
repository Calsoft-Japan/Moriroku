page 50008 MTNA_IF_ProductionOrder_API
{
    //CS 2024/9/5 Channing.Zhou FDD304 Page for MTNA IF Production Order API
    ApplicationArea = All;
    Caption = 'MTNA IF Production Order API';
    PageType = API;
    APIPublisher = 'CalsoftSystems';
    APIGroup = 'MTNAIF';
    APIVersion = 'v2.0';
    EntitySetCaption = 'MTNA IF Production Orders';
    EntitySetName = 'productionOrder';
    EntityCaption = 'MTNA IF Production Order';
    EntityName = 'mtnaIFProductionOrder';
    ODataKeyFields = "Entry No.";
    SourceTable = MTNA_IF_ProductionOrder;
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
                field(Orderdate; Rec."Order date")
                {
                    ApplicationArea = All;
                }
                field(ItemNo; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(APSStartingDate; Rec."APS Starting Date")
                {
                    ApplicationArea = All;
                }
                field(APSStartingTime; Rec."APS Starting Time")
                {
                    ApplicationArea = All;
                }
                field(APSEndingDate; Rec."APS Ending Date")
                {
                    ApplicationArea = All;
                }
                field(APSEndingTime; Rec."APS Ending Time")
                {
                    ApplicationArea = All;
                }
                field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec."Quantity")
                {
                    ApplicationArea = All;
                }
                field(WorkCenterCode; Rec."Work Center Code")
                {
                    ApplicationArea = All;
                }
                field(OrderNumber; Rec."Production Order No.")
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

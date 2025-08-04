page 50010 MTNA_IF_PurchaseReceiving_API
{
    //CS 2024/8/13 Channing.Zhou FDD305 Page for MTNA IF Purchase Receiving API
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Receiving API';
    PageType = API;
    APIPublisher = 'CalsoftSystems';
    APIGroup = 'MTNAIF';
    APIVersion = 'v2.0';
    EntitySetCaption = 'MTNA IF Purchase Receivings';
    EntitySetName = 'purchaseReceiving';
    EntityCaption = 'MTNA IF Purchase Receiving';
    EntityName = 'mtnaIFPurchaseReceiving';
    ODataKeyFields = "Entry No.";
    SourceTable = MTNA_IF_PurchaseReceiving;
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
                field(OrderNo; Rec."Order No.")
                {
                    ApplicationArea = All;
                }
                field(Postingdate; Rec."Posting date")
                {
                    ApplicationArea = All;
                }
                field(VendorShipmentNo; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = All;
                }
                field(LineNo; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field(QtytoReceive; Rec."Qty. to Receive")
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
                field(LotNumber; Rec."Lot Number")
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

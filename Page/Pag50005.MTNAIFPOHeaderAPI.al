page 50005 MTNA_IF_POHeader_API
{
    //CS 2024/8/13 Channing.Zhou FDD302 Page for MTNA IF PO Header API
    ApplicationArea = All;
    Caption = 'MTNA IF PO Header API';
    PageType = API;
    APIPublisher = 'CalsoftSystems';
    APIGroup = 'MTNAIF';
    APIVersion = 'v2.0';
    EntitySetCaption = 'MTNA IF PO Headers';
    EntitySetName = 'purchaseOrder';
    EntityCaption = 'MTNA IF PO Header';
    EntityName = 'mtnaIFPOHeader';
    ODataKeyFields = "Entry No.";
    SourceTable = MTNA_IF_POHeaders;
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
                field(EntryNo;
                Rec."Entry No.")
                {
                    Visible = false;
                    Editable = false;
                }
                field(Plant; Rec.Plant)
                {
                    ApplicationArea = All;
                }
                field(OrderID; Rec."Order ID")
                {
                    ApplicationArea = All;
                }
                field(VendorNo; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                }
                field(YourReference; Rec."Your Reference")
                {
                    ApplicationArea = All;
                }
                field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(OrderDate; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field(ShipmentMethodCode; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                field(ResponsibilityCenter; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                }
                field(RequestedReceiptDate; Rec."Requested Receipt Date")
                {
                    ApplicationArea = All;
                }
                field(CurrencyCode; Rec."Currency Code")
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
            }
            part(purchaseLine; "MTNA_IF_POLine_API")
            {
                Caption = 'MTNA IF POLines';
                EntityName = 'mtnaIFPOLine';
                EntitySetName = 'purchaseLine';
                SubPageLink = "Header Entry No." = field("Entry No.");
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

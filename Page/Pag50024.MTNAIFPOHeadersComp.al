page 50024 MTNA_IF_POHeadersComp
{
    //CS 2025/10/11 Channing.Zhou FDD302 Page for MTNA IF PO Header Completed
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Orders Completed';
    PageType = List;
    SourceTable = MTNA_IF_POHeaders;
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
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        PagMTNAIFPOLinesComp: Page "MTNA_IF_POLinesComp";
                        RecMTNAIFPOlines: Record "MTNA_IF_POLines";
                    begin
                        if Rec.IsEmpty() = false then begin
                            RecMTNAIFPOlines.Reset();
                            RecMTNAIFPOlines.SetRange("Header Entry No.", Rec."Entry No.");
                            if RecMTNAIFPOlines.FindFirst() then begin
                                PagMTNAIFPOLinesComp.SetPageEditable(false);
                                PagMTNAIFPOLinesComp.SetTableView(RecMTNAIFPOlines);
                                PagMTNAIFPOLinesComp.SetRecord(RecMTNAIFPOlines);
                                PagMTNAIFPOLinesComp.RunModal();
                            end
                        end;
                    end;
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
                field(OrderID; Rec."Order ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(VendorNo; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(YourReference; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(OrderDate; Rec."Order Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ShipmentMethodCode; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ResponsibilityCenter; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(RequestedReceiptDate; Rec."Requested Receipt Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(CurrencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
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

    trigger OnAfterGetRecord()
    var
        inStream: InStream;
    begin
        Errormessage := Rec.GetErrormessage();
    end;

    var
        Errormessage: Text;
}

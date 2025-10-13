page 50026 MTNA_IF_POHeadersArc
{
    //CS 2025/10/11 Channing.Zhou FDD302 Page for MTNA IF PO Header Archive
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Orders Arcive';
    PageType = List;
    SourceTable = MTNA_IF_POHeadersArchive;
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
                        PagMTNAIFPOLinesArc: Page "MTNA_IF_POLinesArc";
                        RecMTNAIFPOlinesArchive: Record "MTNA_IF_POLinesArchive";
                    begin
                        if Rec.IsEmpty() = false then begin
                            RecMTNAIFPOlinesArchive.Reset();
                            RecMTNAIFPOlinesArchive.SetRange("Header Entry No.", Rec."Entry No.");
                            if RecMTNAIFPOlinesArchive.FindFirst() then begin
                                PagMTNAIFPOLinesArc.SetPageEditable(false);
                                PagMTNAIFPOLinesArc.SetTableView(RecMTNAIFPOlinesArchive);
                                PagMTNAIFPOLinesArc.SetRecord(RecMTNAIFPOlinesArchive);
                                PagMTNAIFPOLinesArc.RunModal();
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
    actions
    {
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Archive Process"; "Archive")
                {
                }
            }
        }
        area(Processing)
        {
            action("Archive")
            {
                ApplicationArea = All;
                Image = Archive;
                ToolTip = 'Adding temporary for unit testing';

                trigger OnAction()
                var
                    RecSelectedPOHeader: Record "MTNA_IF_POHeaders";
                    CuMTNAIFPurchaseOrderProcArc: Codeunit "MTNAIFPurchaseOrderProcArc";
                    ErrorRecCount: Integer;
                begin
                    RecSelectedPOHeader.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                    if (RecSelectedPOHeader.IsEmpty() = false) And (RecSelectedPOHeader.FindFirst()) then begin
                        RecSelectedPOHeader.SetFilter(Status, '<> %1', RecSelectedPOHeader.Status::Completed);
                        if (RecSelectedPOHeader.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPOHeader.Status::Completed) + ''' status.');
                            exit;
                        end
                        else if Confirm('Move the selected records to Archive?') = true then begin
                            RecSelectedPOHeader.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                            if RecSelectedPOHeader.FindFirst() then begin
                                if CuMTNAIFPurchaseOrderProcArc.ProcArcPurchaseOrderData(RecSelectedPOHeader, ErrorRecCount) then begin
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

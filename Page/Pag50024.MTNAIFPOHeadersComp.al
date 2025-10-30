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
                    RecMTNAIFConfiguration: record "MTNA IF Configuration";
                    HoursNoArc: Integer;
                begin
                    HoursNoArc := 0;
                    RecMTNAIFConfiguration.Reset();
                    RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Purchase order");
                    if RecMTNAIFConfiguration.FindFirst() then begin
                        HoursNoArc := RecMTNAIFConfiguration."Hours no to acrhive";
                    end;
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
                                if CuMTNAIFPurchaseOrderProcArc.ProcArcPurchaseOrderData(RecSelectedPOHeader, HoursNoArc, ErrorRecCount) then begin
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

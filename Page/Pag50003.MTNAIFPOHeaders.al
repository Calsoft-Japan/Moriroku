page 50003 MTNA_IF_POHeaders
{
    //CS 2024/9/3 Channing.Zhou FDD302 Page for MTNA IF PO Header
    //CS 2025/10/11 Channing.Zhou FDD300 V7.0 The page will only shows the Ready records and add delete button to the page.
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Orders';
    PageType = List;
    SourceTable = MTNA_IF_POHeaders;
    SourceTableView = where("Status" = const("MTNA IF Status"::Ready));
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;

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
                        PagMTNAIFPOLines: Page "MTNA_IF_POLines";
                        RecMTNAIFPOlines: Record "MTNA_IF_POLines";
                    begin
                        if Rec.IsEmpty() = false then begin
                            RecMTNAIFPOlines.Reset();
                            RecMTNAIFPOlines.SetRange("Header Entry No.", Rec."Entry No.");
                            if RecMTNAIFPOlines.FindFirst() then begin
                                if Rec.Status = Rec.Status::Ready then begin
                                    PagMTNAIFPOLines.SetPageEditable(true);
                                end
                                else begin
                                    PagMTNAIFPOLines.SetPageEditable(false);
                                end;
                                PagMTNAIFPOLines.SetTableView(RecMTNAIFPOlines);
                                PagMTNAIFPOLines.SetRecord(RecMTNAIFPOlines);
                                PagMTNAIFPOLines.RunModal();
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
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field(VendorNo; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field(YourReference; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field(OrderDate; Rec."Order Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field(ShipmentMethodCode; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field(ResponsibilityCenter; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field(RequestedReceiptDate; Rec."Requested Receipt Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field(CurrencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
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

                actionref("Rerun Process"; Rerun)
                {
                }

                actionref("Delete Process"; Delete)
                {
                }
            }
        }

        area(Processing)
        {
            action("Delete")
            {
                ApplicationArea = All;
                Image = Delete;

                trigger OnAction()
                var
                    RecSelectedPOHeader: Record "MTNA_IF_POHeaders";
                    RecMTNA_IF_POLines: Record MTNA_IF_POLines;
                begin
                    RecSelectedPOHeader.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                    if (RecSelectedPOHeader.IsEmpty() = false) And (RecSelectedPOHeader.FindFirst()) then begin
                        RecSelectedPOHeader.SetFilter(Status, '<> %1', RecSelectedPOHeader.Status::Ready);
                        if (RecSelectedPOHeader.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPOHeader.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedPOHeader.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                            if RecSelectedPOHeader.FindFirst() then begin
                                RecMTNA_IF_POLines.Reset();
                                RecMTNA_IF_POLines.SetRange("Header Entry No.", Rec."Entry No.");
                                if RecMTNA_IF_POLines.FindFirst() then begin
                                    RecMTNA_IF_POLines.DeleteAll();
                                end;
                                RecSelectedPOHeader.DeleteAll();
                                Message('Deleted successfuly.');
                            end;
                        end;
                    end;
                end;
            }

            action("Rerun")
            {
                ApplicationArea = All;
                Image = Process;
                ToolTip = 'Keeping temporary for unit testing';
                trigger OnAction()
                var
                    RecSelectedPOHeader: Record "MTNA_IF_POHeaders";
                    CuMTNAIFPurchaseOrderProcess: Codeunit "MTNAIFPurchaseOrderProcess";
                    ErrorRecCount: Integer;
                begin
                    RecSelectedPOHeader.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                    if (RecSelectedPOHeader.IsEmpty() = false) And (RecSelectedPOHeader.FindFirst()) then begin
                        RecSelectedPOHeader.SetFilter(Status, '<> %1', RecSelectedPOHeader.Status::Ready);
                        if (RecSelectedPOHeader.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPOHeader.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the interface program?') = true then begin
                            RecSelectedPOHeader.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                            if RecSelectedPOHeader.FindFirst() then begin
                                if CuMTNAIFPurchaseOrderProcess.ProcessPurchaseOrderData(RecSelectedPOHeader, ErrorRecCount) then begin
                                    if ErrorRecCount = 0 then begin
                                        Message('All selected records were re-processed.');
                                    end
                                    else begin
                                        Message('Selected records were re-processed with ' + Format(ErrorRecCount) + ' error(s).');
                                    end;
                                end
                                else begin
                                    Message('Selected records were re-processed with error(s).');
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

    trigger OnDeleteRecord(): Boolean
    var
        RecMTNA_IF_POLines: Record MTNA_IF_POLines;
    begin
        RecMTNA_IF_POLines.Reset();
        RecMTNA_IF_POLines.SetRange("Header Entry No.", Rec."Entry No.");
        if RecMTNA_IF_POLines.FindFirst() then begin
            RecMTNA_IF_POLines.DeleteAll();
        end;
        exit(true);
    end;

    var
        Errormessage: Text;
}

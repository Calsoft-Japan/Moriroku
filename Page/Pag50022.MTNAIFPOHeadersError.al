page 50022 MTNA_IF_POHeadersErr
{
    //CS 2025/10/11 Channing.Zhou FDD302 Page for MTNA IF PO Header Error
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Orders Error';
    PageType = List;
    SourceTable = MTNA_IF_POHeaders;
    SourceTableView = where("Status" = const("MTNA IF Status"::Error));
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
                        PagMTNAIFPOLinesError: Page "MTNA_IF_POLinesErr";
                        RecMTNAIFPOlines: Record "MTNA_IF_POLines";
                    begin
                        if Rec.IsEmpty() = false then begin
                            RecMTNAIFPOlines.Reset();
                            RecMTNAIFPOlines.SetRange("Header Entry No.", Rec."Entry No.");
                            if RecMTNAIFPOlines.FindFirst() then begin
                                if Rec.Status = Rec.Status::Error then begin
                                    PagMTNAIFPOLinesError.SetPageEditable(true);
                                end
                                else begin
                                    PagMTNAIFPOLinesError.SetPageEditable(false);
                                end;
                                PagMTNAIFPOLinesError.SetTableView(RecMTNAIFPOlines);
                                PagMTNAIFPOLinesError.SetRecord(RecMTNAIFPOlines);
                                PagMTNAIFPOLinesError.RunModal();
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
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field(VendorNo; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field(YourReference; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field(OrderDate; Rec."Order Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field(ShipmentMethodCode; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field(ResponsibilityCenter; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field(RequestedReceiptDate; Rec."Requested Receipt Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field(CurrencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
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

                actionref("Delete Process"; Delete)
                {
                }

                actionref("Rerun Process"; Rerun)
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
                        RecSelectedPOHeader.SetFilter(Status, '<> %1', RecSelectedPOHeader.Status::Completed);
                        if (RecSelectedPOHeader.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPOHeader.Status::Error) + ''' status.');
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

                trigger OnAction()
                var
                    RecSelectedPOHeader: Record "MTNA_IF_POHeaders";
                    RecMTNA_IF_POLines: Record MTNA_IF_POLines;
                begin
                    RecSelectedPOHeader.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                    if (RecSelectedPOHeader.IsEmpty() = false) And (RecSelectedPOHeader.FindFirst()) then begin
                        RecSelectedPOHeader.SetFilter(Status, '<> %1', RecSelectedPOHeader.Status::Error);
                        if (RecSelectedPOHeader.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPOHeader.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the interface program?') = true then begin
                            RecSelectedPOHeader.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                            if RecSelectedPOHeader.FindFirst() then begin
                                repeat
                                    RecSelectedPOHeader.Status := RecSelectedPOHeader.Status::Ready;
                                    RecSelectedPOHeader."Process start datetime" := 0DT;
                                    RecSelectedPOHeader."Processed datetime" := 0DT;
                                    RecSelectedPOHeader.SetErrormessage('');
                                    RecSelectedPOHeader.Modify();
                                    RecMTNA_IF_POLines.Reset();
                                    RecMTNA_IF_POLines.SetRange("Header Entry No.", Rec."Entry No.");
                                    if RecMTNA_IF_POLines.FindFirst() then begin
                                        repeat
                                            RecMTNA_IF_POLines.Status := RecMTNA_IF_POLines.Status::Ready;
                                            RecMTNA_IF_POLines."Process start datetime" := 0DT;
                                            RecMTNA_IF_POLines."Processed datetime" := 0DT;
                                            RecMTNA_IF_POLines.SetErrormessage('');
                                            RecMTNA_IF_POLines.Modify();
                                        until RecMTNA_IF_POLines.Next() = 0;
                                    end;
                                until RecSelectedPOHeader.Next() = 0;
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

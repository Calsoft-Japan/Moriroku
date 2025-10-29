page 50026 MTNA_IF_POHeadersArc
{
    //CS 2025/10/11 Channing.Zhou FDD302 Page for MTNA IF PO Header Archive
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Orders Archive';
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
                            RecMTNAIFPOlinesArchive.SetRange("Header Archive Entry No.", Rec."Archive Entry No.");
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
                    RecSelectedPOHeaderArchive: Record "MTNA_IF_POHeadersArchive";
                    RecMTNA_IF_POLinesArchive: Record MTNA_IF_POLinesArchive;
                begin
                    RecSelectedPOHeaderArchive.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPOHeaderArchive);
                    if (RecSelectedPOHeaderArchive.IsEmpty() = false) And (RecSelectedPOHeaderArchive.FindFirst()) then begin
                        RecSelectedPOHeaderArchive.SetFilter(Status, '<> %1', RecSelectedPOHeaderArchive.Status::Completed);
                        if (RecSelectedPOHeaderArchive.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPOHeaderArchive.Status::Completed) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedPOHeaderArchive.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPOHeaderArchive);
                            if RecSelectedPOHeaderArchive.FindFirst() then begin
                                RecMTNA_IF_POLinesArchive.Reset();
                                RecMTNA_IF_POLinesArchive.SetRange("Header Archive Entry No.", Rec."Archive Entry No.");
                                if RecMTNA_IF_POLinesArchive.FindFirst() then begin
                                    RecMTNA_IF_POLinesArchive.DeleteAll();
                                end;
                                RecSelectedPOHeaderArchive.DeleteAll();
                                Message('Deleted successfuly.');
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

page 50003 MTNA_IF_POHeaders
{
    //CS 2024/9/3 Channing.Zhou FDD302 Page for MTNA IF PO Header
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Orders';
    PageType = List;
    SourceTable = MTNA_IF_POHeaders;
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;

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
                                if Rec.Status = Rec.Status::New then begin
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
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(VendorNo; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(YourReference; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(OrderDate; Rec."Order Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(ShipmentMethodCode; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(ResponsibilityCenter; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(RequestedReceiptDate; Rec."Requested Receipt Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(CurrencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
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
                actionref("Copy Records"; Copy)
                {
                }
                actionref("Change Records Status"; "Change Status")
                {
                }
                actionref("Rerun Process"; Rerun)
                {
                }
            }
        }
        area(Processing)
        {
            action(Copy)
            {
                ApplicationArea = All;
                Image = CopyDocument;
                trigger OnAction()
                var
                    RecSelectedPOHeader: Record "MTNA_IF_POHeaders";
                    RecSelectedPOLine: Record "MTNA_IF_POLines";
                    RecMTNAIFPOHeader: Record "MTNA_IF_POHeaders";
                    RecMTNAIFPOLine: Record "MTNA_IF_POLines";
                    "Last Header Entry No.": Integer;
                    "Last Line Entry No.": Integer;
                begin
                    RecSelectedPOHeader.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                    if (RecSelectedPOHeader.IsEmpty() = false) And (RecSelectedPOHeader.FindFirst()) then begin
                        repeat
                            RecMTNAIFPOHeader.Reset();
                            if RecMTNAIFPOHeader.FindLast() then begin
                                "Last Header Entry No." := RecMTNAIFPOHeader."Entry No.";
                                "Last Header Entry No." += 1;
                                RecMTNAIFPOHeader.Init();
                                RecMTNAIFPOHeader := RecSelectedPOHeader;
                                RecMTNAIFPOHeader."Entry No." := "Last Header Entry No.";
                                RecMTNAIFPOHeader.Status := RecMTNAIFPOHeader.Status::New;
                                RecMTNAIFPOHeader."Created datetime" := CurrentDateTime;
                                RecMTNAIFPOHeader."Process start datetime" := 0DT;
                                RecMTNAIFPOHeader."Processed datetime" := 0DT;
                                RecMTNAIFPOHeader.SetErrormessage('');
                                RecMTNAIFPOHeader.Insert(true);
                                RecSelectedPOLine.Reset();
                                RecSelectedPOLine.SetRange("Header Entry No.", RecSelectedPOHeader."Entry No.");
                                if RecSelectedPOLine.FindFirst() then begin
                                    repeat
                                        RecMTNAIFPOLine.Reset();
                                        if RecMTNAIFPOLine.FindLast() then begin
                                            "Last Line Entry No." := RecMTNAIFPOLine."Entry No.";
                                        end;
                                        "Last Line Entry No." += 1;
                                        RecMTNAIFPOLine.Init();
                                        RecMTNAIFPOLine := RecSelectedPOLine;
                                        RecMTNAIFPOLine."Entry No." := "Last Line Entry No.";
                                        RecMTNAIFPOLine."Header Entry No." := "Last Header Entry No.";
                                        RecMTNAIFPOLine.Status := RecMTNAIFPOLine.Status::New;
                                        RecMTNAIFPOLine."Created datetime" := CurrentDateTime;
                                        RecMTNAIFPOLine."Process start datetime" := 0DT;
                                        RecMTNAIFPOLine."Processed datetime" := 0DT;
                                        RecMTNAIFPOLine.SetErrormessage('');
                                        RecMTNAIFPOLine.Insert(true);
                                    until RecSelectedPOLine.Next() = 0;
                                end;
                            end;
                        until RecSelectedPOHeader.Next() = 0;
                    end;
                end;
            }
            action("Change status")
            {
                ApplicationArea = All;
                Image = ChangeStatus;
                trigger OnAction()
                var
                    RecSelectedPOHeader: Record "MTNA_IF_POHeaders";
                    RecSelectedPOLine: Record "MTNA_IF_POLines";
                begin
                    RecSelectedPOHeader.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                    if (RecSelectedPOHeader.IsEmpty() = false) And (RecSelectedPOHeader.FindFirst()) then begin
                        RecSelectedPOHeader.SetFilter(Status, '<> %1', RecSelectedPOHeader.Status::New);
                        if (RecSelectedPOHeader.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPOHeader.Status::New) + ''' Status.');
                            exit;
                        end
                        else if Confirm('Change status to ''' + Format(RecSelectedPOHeader.Status::Ready) + '''?') = true then begin
                            RecSelectedPOHeader.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPOHeader);
                            if RecSelectedPOHeader.FindFirst() then begin
                                repeat
                                    RecSelectedPOHeader.Status := RecSelectedPOHeader.Status::Ready;
                                    RecSelectedPOHeader.Modify(true);
                                    RecSelectedPOLine.Reset();
                                    RecSelectedPOLine.SetRange("Header Entry No.", RecSelectedPOHeader."Entry No.");
                                    if RecSelectedPOLine.FindFirst() then begin
                                        repeat
                                            RecSelectedPOLine.Status := RecSelectedPOLine.Status::Ready;
                                            RecSelectedPOLine.Modify(true);
                                        until RecSelectedPOLine.Next() = 0;
                                    end;
                                until RecSelectedPOHeader.Next() = 0;
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

    var
        Errormessage: Text;
}

page 50031 MTNA_IF_PurchaseReceivingError
{
    //CS 2025/10/15 Channing.Zhou FDD305 Page for MTNA IF Purchase Receiving Error
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Receiving Error';
    PageType = List;
    SourceTable = MTNA_IF_PurchaseReceiving;
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
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Lot Number"; Rec."Lot Number")
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
                    RecSelectedPurchaseReceivingArchive: Record "MTNA_IF_PurchaseReceivingArc";
                begin
                    RecSelectedPurchaseReceivingArchive.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPurchaseReceivingArchive);
                    if (RecSelectedPurchaseReceivingArchive.IsEmpty() = false) And (RecSelectedPurchaseReceivingArchive.FindFirst()) then begin
                        RecSelectedPurchaseReceivingArchive.SetFilter(Status, '<> %1', RecSelectedPurchaseReceivingArchive.Status::Completed);
                        if (RecSelectedPurchaseReceivingArchive.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPurchaseReceivingArchive.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedPurchaseReceivingArchive.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPurchaseReceivingArchive);
                            if RecSelectedPurchaseReceivingArchive.FindFirst() then begin
                                RecSelectedPurchaseReceivingArchive.DeleteAll();
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
                    RecSelectedPurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
                    CuMTNAIFPurchaseReceivingProcess: Codeunit "MTNAIFPurchaseReceivingProcess";
                    ErrorRecCount: Integer;
                begin
                    RecSelectedPurchaseReceiving.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                    if (RecSelectedPurchaseReceiving.IsEmpty() = false) And (RecSelectedPurchaseReceiving.FindFirst()) then begin
                        RecSelectedPurchaseReceiving.SetFilter(Status, '<> %1', RecSelectedPurchaseReceiving.Status::Ready);
                        if (RecSelectedPurchaseReceiving.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPurchaseReceiving.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the interface program?') = true then begin
                            RecSelectedPurchaseReceiving.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                            if RecSelectedPurchaseReceiving.FindFirst() then begin
                                if CuMTNAIFPurchaseReceivingProcess.ProcessPurchaseReceivingData(RecSelectedPurchaseReceiving, ErrorRecCount) then begin
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

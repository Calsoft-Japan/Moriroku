page 50031 MTNA_IF_PurchaseReceivingErr
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
                    RecSelectedPurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
                begin
                    RecSelectedPurchaseReceiving.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                    if (RecSelectedPurchaseReceiving.IsEmpty() = false) And (RecSelectedPurchaseReceiving.FindFirst()) then begin
                        RecSelectedPurchaseReceiving.SetFilter(Status, '<> %1', RecSelectedPurchaseReceiving.Status::Error);
                        if (RecSelectedPurchaseReceiving.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPurchaseReceiving.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedPurchaseReceiving.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                            if RecSelectedPurchaseReceiving.FindFirst() then begin
                                RecSelectedPurchaseReceiving.DeleteAll();
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
                    RecSelectedPurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
                begin
                    RecSelectedPurchaseReceiving.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                    if (RecSelectedPurchaseReceiving.IsEmpty() = false) And (RecSelectedPurchaseReceiving.FindFirst()) then begin
                        RecSelectedPurchaseReceiving.SetFilter(Status, '<> %1', RecSelectedPurchaseReceiving.Status::Error);
                        if (RecSelectedPurchaseReceiving.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPurchaseReceiving.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the selected records?') = true then begin
                            RecSelectedPurchaseReceiving.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                            if RecSelectedPurchaseReceiving.FindFirst() then begin
                                repeat
                                    RecSelectedPurchaseReceiving.Status := RecSelectedPurchaseReceiving.Status::Ready;
                                    RecSelectedPurchaseReceiving."Process start datetime" := 0DT;
                                    RecSelectedPurchaseReceiving."Processed datetime" := 0DT;
                                    RecSelectedPurchaseReceiving.SetErrormessage('');
                                    RecSelectedPurchaseReceiving.Modify();
                                until RecSelectedPurchaseReceiving.Next() = 0;
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

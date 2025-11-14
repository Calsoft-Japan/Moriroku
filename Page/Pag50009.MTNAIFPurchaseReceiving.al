page 50009 MTNA_IF_PurchaseReceiving
{
    //CS 2024/8/13 Channing.Zhou FDD305 Page for MTNA IF Purchase Receiving
    //CS 2025/10/15 Channing.Zhou FDD300 V7.0 The page will only shows the Ready records and add delete button to the page.
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Receiving';
    PageType = List;
    SourceTable = MTNA_IF_PurchaseReceiving;
    SourceTableView = where("Status" = const("MTNA IF Status"::Ready));
    UsageCategory = Administration;
    DeleteAllowed = true;
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
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Ready;
                }
                field("Lot Number"; Rec."Lot Number")
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
                    RecSelectedPurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
                begin
                    RecSelectedPurchaseReceiving.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                    if (RecSelectedPurchaseReceiving.IsEmpty() = false) And (RecSelectedPurchaseReceiving.FindFirst()) then begin
                        RecSelectedPurchaseReceiving.SetFilter(Status, '<> %1', RecSelectedPurchaseReceiving.Status::Completed);
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

page 50033 MTNA_IF_PurchaseReceivingArc
{
    //CS 2025/10/15 Channing.Zhou FDD305 Page for MTNA IF Purchase Receiving Archive
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Receiving Archive';
    PageType = List;
    SourceTable = MTNA_IF_PurchaseReceivingArc;
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
                    Editable = false;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Lot Number"; Rec."Lot Number")
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
                    RecSelectedPurchaseReceivingArchive: Record "MTNA_IF_PurchaseReceivingArc";
                begin
                    RecSelectedPurchaseReceivingArchive.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPurchaseReceivingArchive);
                    if (RecSelectedPurchaseReceivingArchive.IsEmpty() = false) And (RecSelectedPurchaseReceivingArchive.FindFirst()) then begin
                        RecSelectedPurchaseReceivingArchive.SetFilter(Status, '<> %1', RecSelectedPurchaseReceivingArchive.Status::Completed);
                        if (RecSelectedPurchaseReceivingArchive.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPurchaseReceivingArchive.Status::Completed) + ''' status.');
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

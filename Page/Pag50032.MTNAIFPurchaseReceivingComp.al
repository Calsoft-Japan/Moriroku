page 50032 MTNA_IF_PurchaseReceivingComp
{
    //CS 2025/10/15 Channing.Zhou FDD305 Page for MTNA IF Purchase Receiving Completed
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Receiving Completed';
    PageType = List;
    SourceTable = MTNA_IF_PurchaseReceiving;
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
                actionref("Archive Process"; Archive)
                {
                }
            }
        }
        area(Processing)
        {
            action(Archive)
            {
                ApplicationArea = All;
                Image = Archive;
                ToolTip = 'Adding temporary for unit testing';

                trigger OnAction()
                var
                    RecSelectedPurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
                    CuMTNAIFPurchaseReceivingProcArc: Codeunit "MTNAIFPurchaseReceivingProcArc";
                    ErrorRecCount: Integer;
                    RecMTNAIFConfiguration: record "MTNA IF Configuration";
                    HoursNoArc: Integer;
                begin
                    HoursNoArc := 0;
                    RecMTNAIFConfiguration.Reset();
                    RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Purchase receiving");
                    if RecMTNAIFConfiguration.FindFirst() then begin
                        HoursNoArc := RecMTNAIFConfiguration."Hours no to acrhive";
                    end;
                    RecSelectedPurchaseReceiving.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                    if (RecSelectedPurchaseReceiving.IsEmpty() = false) And (RecSelectedPurchaseReceiving.FindFirst()) then begin
                        RecSelectedPurchaseReceiving.SetFilter(Status, '<> %1', RecSelectedPurchaseReceiving.Status::Completed);
                        if (RecSelectedPurchaseReceiving.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPurchaseReceiving.Status::Completed) + ''' status.');
                            exit;
                        end
                        else if Confirm('Move the selected records to Archive?') = true then begin
                            RecSelectedPurchaseReceiving.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                            if RecSelectedPurchaseReceiving.FindFirst() then begin
                                if CuMTNAIFPurchaseReceivingProcArc.ProcArcPurchaseReceivingData(RecSelectedPurchaseReceiving, HoursNoArc, ErrorRecCount) then begin
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

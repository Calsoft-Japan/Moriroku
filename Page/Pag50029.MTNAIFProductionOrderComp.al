page 50029 MTNA_IF_ProductionOrderComp
{
    //CS 2025/10/13 Channing.Zhou FDD304 Page for MTNA IF Production Order Completed
    ApplicationArea = All;
    Caption = 'MTNA IF Production Order Completed';
    PageType = List;
    SourceTable = MTNA_IF_ProductionOrder;
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
                field("Order date"; Rec."Order date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("APS Starting Date"; Rec."APS Starting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("APS Starting Time"; Rec."APS Starting Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("APS Ending Date"; Rec."APS Ending Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("APS Ending Time"; Rec."APS Ending Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Work Center Code"; Rec."Work Center Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Production Order No."; Rec."Production Order No.")
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
                    RecSelectedProductionOrder: Record "MTNA_IF_ProductionOrder";
                    CuMTNAIFProductionOrderProcArc: Codeunit "MTNAIFProductionOrderProcArc";
                    ErrorRecCount: Integer;
                    RecMTNAIFConfiguration: record "MTNA IF Configuration";
                    HoursNoArc: Integer;
                begin
                    HoursNoArc := 0;
                    RecMTNAIFConfiguration.Reset();
                    RecMTNAIFConfiguration.SetRange("Batch job", RecMTNAIFConfiguration."Batch job"::"Production order");
                    if RecMTNAIFConfiguration.FindFirst() then begin
                        HoursNoArc := RecMTNAIFConfiguration."Hours no to acrhive";
                    end;
                    RecSelectedProductionOrder.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                    if (RecSelectedProductionOrder.IsEmpty() = false) And (RecSelectedProductionOrder.FindFirst()) then begin
                        RecSelectedProductionOrder.SetFilter(Status, '<> %1', RecSelectedProductionOrder.Status::Completed);
                        if (RecSelectedProductionOrder.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedProductionOrder.Status::Completed) + ''' status.');
                            exit;
                        end
                        else if Confirm('Move the selected records to Archive?') = true then begin
                            RecSelectedProductionOrder.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                            if RecSelectedProductionOrder.FindFirst() then begin
                                if CuMTNAIFProductionOrderProcArc.ProcArcProductionOrderData(RecSelectedProductionOrder, HoursNoArc, ErrorRecCount) then begin
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

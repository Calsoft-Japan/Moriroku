page 50028 MTNA_IF_ProductionOrderErr
{
    //CS 2025/10/13 Channing.Zhou FDD304 Page for MTNA IF Production Order Error
    ApplicationArea = All;
    Caption = 'MTNA IF Production Order Error';
    PageType = List;
    SourceTable = MTNA_IF_ProductionOrder;
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
                field("Order date"; Rec."Order date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("APS Starting Date"; Rec."APS Starting Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("APS Starting Time"; Rec."APS Starting Time")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("APS Ending Date"; Rec."APS Ending Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("APS Ending Time"; Rec."APS Ending Time")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Work Center Code"; Rec."Work Center Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::Error;
                }
                field("Production Order No."; Rec."Production Order No.")
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
                    RecSelectedProductionOrder: Record "MTNA_IF_ProductionOrder";
                begin
                    RecSelectedProductionOrder.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                    if (RecSelectedProductionOrder.IsEmpty() = false) And (RecSelectedProductionOrder.FindFirst()) then begin
                        RecSelectedProductionOrder.SetFilter(Status, '<> %1', RecSelectedProductionOrder.Status::Completed);
                        if (RecSelectedProductionOrder.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedProductionOrder.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedProductionOrder.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                            if RecSelectedProductionOrder.FindFirst() then begin
                                RecSelectedProductionOrder.DeleteAll();
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
                    RecSelectedProductionOrder: Record "MTNA_IF_ProductionOrder";
                begin
                    RecSelectedProductionOrder.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                    if (RecSelectedProductionOrder.IsEmpty() = false) And (RecSelectedProductionOrder.FindFirst()) then begin
                        RecSelectedProductionOrder.SetFilter(Status, '<> %1', RecSelectedProductionOrder.Status::Error);
                        if (RecSelectedProductionOrder.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedProductionOrder.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the selected records?') = true then begin
                            RecSelectedProductionOrder.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                            if RecSelectedProductionOrder.FindFirst() then begin
                                repeat
                                    RecSelectedProductionOrder.Status := RecSelectedProductionOrder.Status::Ready;
                                    RecSelectedProductionOrder."Process start datetime" := 0DT;
                                    RecSelectedProductionOrder."Processed datetime" := 0DT;
                                    RecSelectedProductionOrder.SetErrormessage('');
                                    RecSelectedProductionOrder.Modify();
                                until RecSelectedProductionOrder.Next() = 0;
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

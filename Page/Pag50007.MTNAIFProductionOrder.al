page 50007 MTNA_IF_ProductionOrder
{
    //CS 2024/9/5 Channing.Zhou FDD304 Page for MTNA IF Production Order
    ApplicationArea = All;
    Caption = 'MTNA IF Production Order';
    PageType = List;
    SourceTable = MTNA_IF_ProductionOrder;
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
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("APS Starting Date"; Rec."APS Starting Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("APS Starting Time"; Rec."APS Starting Time")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("APS Ending Date"; Rec."APS Ending Date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("APS Ending Time"; Rec."APS Ending Time")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Work Center Code"; Rec."Work Center Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Production Order No."; Rec."Production Order No.")
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
                    RecSelectedProductionOrder: Record "MTNA_IF_ProductionOrder";
                    RecMTNAIFProductionOrder: Record "MTNA_IF_ProductionOrder";
                    "Last Entry No.": Integer;
                begin
                    RecSelectedProductionOrder.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                    if (RecSelectedProductionOrder.IsEmpty() = false) And (RecSelectedProductionOrder.FindFirst()) then begin
                        repeat
                            RecMTNAIFProductionOrder.Reset();
                            if RecMTNAIFProductionOrder.FindLast() then begin
                                "Last Entry No." := RecMTNAIFProductionOrder."Entry No.";
                                "Last Entry No." += 1;
                                RecMTNAIFProductionOrder.Init();
                                RecMTNAIFProductionOrder := RecSelectedProductionOrder;
                                RecMTNAIFProductionOrder."Entry No." := "Last Entry No.";
                                RecMTNAIFProductionOrder.Status := RecMTNAIFProductionOrder.Status::New;
                                RecMTNAIFProductionOrder."Created datetime" := CurrentDateTime;
                                RecMTNAIFProductionOrder."Process start datetime" := 0DT;
                                RecMTNAIFProductionOrder."Processed datetime" := 0DT;
                                RecMTNAIFProductionOrder.SetErrormessage('');
                                RecMTNAIFProductionOrder.Insert(true);
                            end;
                        until RecSelectedProductionOrder.Next() = 0;
                    end;
                end;
            }
            action("Change status")
            {
                ApplicationArea = All;
                Image = ChangeStatus;
                trigger OnAction()
                var
                    RecSelectedProductionOrder: Record "MTNA_IF_ProductionOrder";
                begin
                    RecSelectedProductionOrder.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                    if (RecSelectedProductionOrder.IsEmpty() = false) And (RecSelectedProductionOrder.FindFirst()) then begin
                        RecSelectedProductionOrder.SetFilter(Status, '<> %1', RecSelectedProductionOrder.Status::New);
                        if (RecSelectedProductionOrder.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedProductionOrder.Status::New) + ''' Status.');
                            exit;
                        end
                        else if Confirm('Change status to ''' + Format(RecSelectedProductionOrder.Status::Ready) + '''?') = true then begin
                            RecSelectedProductionOrder.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                            if RecSelectedProductionOrder.FindFirst() then begin
                                repeat
                                    RecSelectedProductionOrder.Status := RecSelectedProductionOrder.Status::Ready;
                                    RecSelectedProductionOrder.Modify(true);
                                until RecSelectedProductionOrder.Next() = 0;
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
                    CuMTNAIFProductionOrderProcess: Codeunit "MTNAIFProductionOrderProcess";
                    ErrorRecCount: Integer;
                begin
                    RecSelectedProductionOrder.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                    if (RecSelectedProductionOrder.IsEmpty() = false) And (RecSelectedProductionOrder.FindFirst()) then begin
                        RecSelectedProductionOrder.SetFilter(Status, '<> %1', RecSelectedProductionOrder.Status::Ready);
                        if (RecSelectedProductionOrder.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedProductionOrder.Status::Ready) + ''' status.');
                            exit;
                        end
                        else if Confirm('Re-run the interface program?') = true then begin
                            RecSelectedProductionOrder.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedProductionOrder);
                            if RecSelectedProductionOrder.FindFirst() then begin
                                if CuMTNAIFProductionOrderProcess.ProcessProductionOrderData(RecSelectedProductionOrder, ErrorRecCount) then begin
                                    if ErrorRecCount = 0 then begin
                                        Message('All selected records were re-processed.');
                                    end
                                    else begin
                                        Message('Selected records were re-processed with ' + Format(ErrorRecCount) + ' error (s).');
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

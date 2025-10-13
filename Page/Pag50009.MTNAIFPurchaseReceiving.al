page 50009 MTNA_IF_PurchaseReceiving
{
    //CS 2024/8/13 Channing.Zhou FDD301 Page for MTNA IF Purchase Receiving
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Receiving';
    PageType = List;
    SourceTable = MTNA_IF_PurchaseReceiving;
    SourceTableView = where("Status" = const("MTNA IF Status"::Ready));
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
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field("Lot Number"; Rec."Lot Number")
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
                    RecSelectedPurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
                    RecMTNAIFPurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
                    "Last Entry No.": Integer;
                begin
                    RecSelectedPurchaseReceiving.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                    if (RecSelectedPurchaseReceiving.IsEmpty() = false) And (RecSelectedPurchaseReceiving.FindFirst()) then begin
                        repeat
                            RecMTNAIFPurchaseReceiving.Reset();
                            if RecMTNAIFPurchaseReceiving.FindLast() then begin
                                "Last Entry No." := RecMTNAIFPurchaseReceiving."Entry No.";
                                "Last Entry No." += 1;
                                RecMTNAIFPurchaseReceiving.Init();
                                RecMTNAIFPurchaseReceiving := RecSelectedPurchaseReceiving;
                                RecMTNAIFPurchaseReceiving."Entry No." := "Last Entry No.";
                                RecMTNAIFPurchaseReceiving.Status := RecMTNAIFPurchaseReceiving.Status::New;
                                RecMTNAIFPurchaseReceiving."Created datetime" := CurrentDateTime;
                                RecMTNAIFPurchaseReceiving."Process start datetime" := 0DT;
                                RecMTNAIFPurchaseReceiving."Processed datetime" := 0DT;
                                RecMTNAIFPurchaseReceiving.SetErrormessage('');
                                RecMTNAIFPurchaseReceiving.Insert(true);
                            end;
                        until RecSelectedPurchaseReceiving.Next() = 0;
                    end;
                end;
            }
            action("Change status")
            {
                ApplicationArea = All;
                Image = ChangeStatus;
                trigger OnAction()
                var
                    RecSelectedPurchaseReceiving: Record "MTNA_IF_PurchaseReceiving";
                begin
                    RecSelectedPurchaseReceiving.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                    if (RecSelectedPurchaseReceiving.IsEmpty() = false) And (RecSelectedPurchaseReceiving.FindFirst()) then begin
                        RecSelectedPurchaseReceiving.SetFilter(Status, '<> %1', RecSelectedPurchaseReceiving.Status::New);
                        if (RecSelectedPurchaseReceiving.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedPurchaseReceiving.Status::New) + ''' Status.');
                            exit;
                        end
                        else if Confirm('Change status to ''' + Format(RecSelectedPurchaseReceiving.Status::Ready) + '''?') = true then begin
                            RecSelectedPurchaseReceiving.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedPurchaseReceiving);
                            if RecSelectedPurchaseReceiving.FindFirst() then begin
                                repeat
                                    RecSelectedPurchaseReceiving.Status := RecSelectedPurchaseReceiving.Status::Ready;
                                    RecSelectedPurchaseReceiving.Modify(true);
                                until RecSelectedPurchaseReceiving.Next() = 0;
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

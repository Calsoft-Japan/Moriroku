page 50030 MTNA_IF_ProductionOrderArc
{
    //CS 2025/10/13 Channing.Zhou FDD304 Page for MTNA IF Production Order Archive
    ApplicationArea = All;
    Caption = 'MTNA IF Production Order Archive';
    PageType = List;
    SourceTable = MTNA_IF_ProductionOrderArchive;
    SourceTableView = where("Status" = const("MTNA IF Status"::Completed));
    UsageCategory = Administration;
    DeleteAllowed = true;
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
                    RecSelectedProductionOrderArchive: Record "MTNA_IF_ProductionOrderArchive";
                begin
                    RecSelectedProductionOrderArchive.Reset();
                    CurrPage.SetSelectionFilter(RecSelectedProductionOrderArchive);
                    if (RecSelectedProductionOrderArchive.IsEmpty() = false) And (RecSelectedProductionOrderArchive.FindFirst()) then begin
                        RecSelectedProductionOrderArchive.SetFilter(Status, '<> %1', RecSelectedProductionOrderArchive.Status::Completed);
                        if (RecSelectedProductionOrderArchive.FindFirst()) then begin
                            Message('Please only select the records with ''' + Format(RecSelectedProductionOrderArchive.Status::Error) + ''' status.');
                            exit;
                        end
                        else if Confirm('Go ahead and delete?') = true then begin
                            RecSelectedProductionOrderArchive.Reset();
                            CurrPage.SetSelectionFilter(RecSelectedProductionOrderArchive);
                            if RecSelectedProductionOrderArchive.FindFirst() then begin
                                RecSelectedProductionOrderArchive.DeleteAll();
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

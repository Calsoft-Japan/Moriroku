page 50012 MTNA_IF_StandardCost_API
{
    //CS 2024/9/5 Channing.Zhou FDD306 Page for MTNA IF Standard Cost API
    ApplicationArea = All;
    Caption = 'MTNA IF Standard Cost API';
    PageType = API;
    APIPublisher = 'CalsoftSystems';
    APIGroup = 'MTNAIF';
    APIVersion = 'v2.0';
    EntitySetCaption = 'MTNA IF Standard Costs';
    EntitySetName = 'standardCost';
    EntityCaption = 'MTNA IF Standard Cost';
    EntityName = 'mtnaIFStandardCost';
    ODataKeyFields = "Entry No.";
    SourceTable = MTNA_IF_StandardCost;
    Extensible = false;
    DelayedInsert = true;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(EntryNo; Rec."Entry No.")
                {
                    Visible = false;
                    Editable = false;
                }
                field(Plant; Rec.Plant)
                {
                    ApplicationArea = All;
                }
                field(StandardCostWorksheetName; Rec."Standard Cost Worksheet Name")
                {
                    ApplicationArea = All;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(NewStandardCost; Rec."New Standard Cost")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Status := Rec.Status::Ready;
        Rec."Created datetime" := CurrentDateTime;
        Rec.SetErrormessage('');
        if Rec.Insert(true) then begin
            exit(false);
        end
        else begin
            exit(false);
        end;
    end;
}

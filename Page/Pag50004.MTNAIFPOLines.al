page 50004 "MTNA_IF_POLines"
{
    //CS 2024/9/3 Channing.Zhou FDD302 Page for MTNA IF PO Line
    ApplicationArea = All;
    Caption = 'MTNA IF Purchase Order Lines';
    PageType = List;
    SourceTable = MTNA_IF_POLines;
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
                field(OrderID; Rec."Order ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(LineNo; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(Description; Rec."Description")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(Quantity; Rec."Quantity")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(UnitPrice; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(UnitofMeasureCode; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.Status = Rec.Status::New;
                }
                field(LocationCode; Rec."Location Code")
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

    procedure SetPageEditable(IsPageEditable: Boolean)
    begin
        pageEditable := IsPageEditable;
    end;

    trigger OnInit()
    begin
        pageEditable := false;
    end;

    trigger OnOpenPage()
    begin
        Editable := pageEditable;
    end;

    trigger OnAfterGetRecord()
    var
        inStream: InStream;
    begin
        Errormessage := Rec.GetErrormessage();
    end;

    var
        Errormessage: Text;
        pageEditable: Boolean;
}

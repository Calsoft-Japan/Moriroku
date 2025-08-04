page 50018 "Set Dimension"
{
    ApplicationArea = All;
    Caption = 'Set Dimension';
    PageType = Card;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Depart; Depart)
                {
                    Caption = 'DEPARTMENT';
                    TableRelation = "Dimension Value".Code where("Dimension Code" = const('DEPARTMENT'));
                }
                field(Gen; Gen)
                {
                    Caption = 'GENERAL';
                    TableRelation = "Dimension Value".Code where("Dimension Code" = const('GENERAL'));
                }
            }
        }
    }

    protected var
        Depart: Code[20];
        Gen: Code[20];

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::LookupOK then begin

        end;
    end;

    procedure getDims(var DepartDim: Code[20]; var GenDim: Code[20])
    begin
        DepartDim := Depart;
        GenDim := Gen;
    end;
}

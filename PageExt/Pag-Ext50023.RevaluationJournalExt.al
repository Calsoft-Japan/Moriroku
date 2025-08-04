pageextension 50023 "Revaluation Journal Ext." extends "Revaluation Journal"
{
    actions
    {
        addafter("P&osting")
        {
            action(SetDim)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Dimension';
                Image = Dimensions;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;
                ToolTip = 'Set Global Dimensions for all lines.';

                trigger OnAction()
                var
                    ItemJnl: Record "Item Journal Line";
                    SetDim: Page "Set Dimension";
                    NewDepartDim: Code[20];
                    NewGenDim: Code[20];
                    GenLedgerSetup: Record "General Ledger Setup";
                begin
                    GenLedgerSetup.Get();

                    ItemJnl.Reset();
                    ItemJnl.SetRange("Journal Template Name", Rec."Journal Template Name");
                    ItemJnl.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    if ItemJnl.FindFirst() then begin
                        SetDim.LookupMode(true);
                        if SetDim.RunModal() = Action::LookupOK then begin
                            SetDim.GetDims(NewDepartDim, NewGenDim);
                            repeat
                                if GenLedgerSetup."Shortcut Dimension 1 Code" = 'DEPARTMENT' then
                                    ItemJnl.Validate("Shortcut Dimension 1 Code", NewDepartDim);
                                if GenLedgerSetup."Shortcut Dimension 1 Code" = 'GENERAL' then
                                    ItemJnl.Validate("Shortcut Dimension 1 Code", NewGenDim);

                                if GenLedgerSetup."Shortcut Dimension 2 Code" = 'GENERAL' then
                                    ItemJnl.Validate("Shortcut Dimension 2 Code", NewGenDim);
                                if GenLedgerSetup."Shortcut Dimension 2 Code" = 'DEPARTMENT' then
                                    ItemJnl.Validate("Shortcut Dimension 2 Code", NewDepartDim);

                                ItemJnl.Modify(true);
                            until ItemJnl.Next() = 0;
                        end;
                    end;
                end;
            }
        }
    }
}

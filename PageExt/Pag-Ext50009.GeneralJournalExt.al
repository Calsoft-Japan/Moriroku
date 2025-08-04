pageextension 50009 "General Journal Ext" extends "General Journal"
{
    layout
    {
        addafter("Gen. Prod. Posting Group")
        {
            field("ASN Number"; Rec."ASN Number")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    actions
    {
        addafter(Approvals)
        {
            action(COGS_Allocation)
            {
                Caption = 'COGS Allocation';
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                Image = Allocate;

                trigger OnAction()
                var
                    Rpt_COGSAllocation: Report "COGS Allocation FDD113";
                //EntryType: Option Sales,Scrap,Adjustment; 
                begin
                    //Rpt_COGSAllocation.SetEntryType(EntryType::Sales);
                    Rpt_COGSAllocation.Run();
                end;
            }

            /* action(SCRAP_Allocation)
            {
                Caption = 'SCRAP Allocation';
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                Image = Allocate;

                trigger OnAction()
                var
                    Rpt_COGSAllocation: Report "COGS Allocation FDD113";
                    EntryType: Option Sales,Scrap,Adjustment;
                begin
                    Rpt_COGSAllocation.SetEntryType(EntryType::Scrap);
                    Rpt_COGSAllocation.Run();
                end;
            }

            action(ADJUSTMENT_Allocation)
            {
                Caption = 'ADJUSTMENT Allocation';
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                Image = Allocate;

                trigger OnAction()
                var
                    Rpt_COGSAllocation: Report "COGS Allocation FDD113";
                    EntryType: Option Sales,Scrap,Adjustment;
                begin
                    Rpt_COGSAllocation.SetEntryType(EntryType::Adjustment);
                    Rpt_COGSAllocation.Run();
                end;
            } */
        }
    }
}

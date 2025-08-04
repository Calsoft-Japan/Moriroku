pageextension 50021 "Sales & Receivables Setup Ext" extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Document Default Line Type")
        {
            field("Delete Past Due Orders"; Rec."Delete Past Due Orders")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

}

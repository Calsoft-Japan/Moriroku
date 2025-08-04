tableextension 50017 "Sales & Receivables Setup Ext" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50000; "Delete Past Due Orders"; DateFormula)
        {
            Caption = 'Delete Past Due Orders';
            DataClassification = ToBeClassified;
        }
    }
}

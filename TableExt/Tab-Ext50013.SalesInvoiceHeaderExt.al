tableextension 50013 "Sales Invoice Header Ext" extends "Sales Invoice Header"
{
    fields
    {
        modify("Package Tracking No.")
        {
            Caption = 'ASN No.';
        }
    }
}

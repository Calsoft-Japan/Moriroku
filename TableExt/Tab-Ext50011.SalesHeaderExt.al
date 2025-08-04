tableextension 50011 "Sales Header Ext" extends "Sales Header"
{
    fields
    {
        modify("Package Tracking No.")
        {
            Caption = 'ASN No.';
        }
    }
}

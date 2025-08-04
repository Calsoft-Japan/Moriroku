tableextension 50014 "Sales Cr.Memo Header Ext" extends "Sales Cr.Memo Header"
{
    fields
    {
        modify("Package Tracking No.")
        {
            Caption = 'ASN No.';
        }
    }
}

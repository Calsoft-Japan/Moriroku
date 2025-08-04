tableextension 50012 "Sales Shipment Header Ext" extends "Sales Shipment Header"
{
    fields
    {
        modify("Package Tracking No.")
        {
            Caption = 'ASN No.';
        }
    }
}

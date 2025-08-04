tableextension 50010 "Sales Line Archive Ext" extends "Sales Line Archive"
{
    fields
    {
        field(50000; "Shipment Time"; Time)
        {
            Caption = 'Shipment Time';
            Editable = false;
            DataClassification = ToBeClassified;
        }
    }
}

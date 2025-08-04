pageextension 50014 "Sales Order Archive Subform Ex" extends "Sales Order Archive Subform"
{
    layout
    {
        addafter("Shipment Date")
        {
            field("Shipment Time"; Rec."Shipment Time")
            {
                ApplicationArea = Suite;
            }
        }
    }
}

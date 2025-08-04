pageextension 50022 "Location Card Ext." extends "Location Card"
{
    layout
    {
        addafter("Tax Exemption No.")
        {
            field(Plant; Rec.Plant)
            {
                ApplicationArea = Location;
            }
        }
    }
}

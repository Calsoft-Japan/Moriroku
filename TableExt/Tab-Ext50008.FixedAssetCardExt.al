tableextension 50008 "Fixed Asset Card Ext" extends "Fixed Asset"
{
    fields
    {
        field(50001; "Asset(Tag) No."; Code[20])
        {
            Caption = 'Asset(Tag) No.';
        }
        field(50002; "Property Tax"; Code[10])
        {
            Caption = 'Property Tax';
        }
        field(50003; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
        }
        field(50004; "Custodian"; Code[20])
        {
            Caption = 'Custodian';
        }
        field(50005; "Current Year"; Date)
        {
            Caption = 'Current Year';
        }
        field(50006; "Alpha Code"; Code[10])
        {
            Caption = 'Alpha Code';
        }
        field(50007; "Numeric Code"; Code[10])
        {
            Caption = 'Numeric Code';
        }
        field(50008; "Tool/Budget#"; Code[10])
        {
            Caption = 'Tool/Budget #';
        }
        field(50009; "Asset Loc-St"; Text[100])
        {
            Caption = 'Asset Loc-St';
        }
        field(50010; "Mfg Vendor"; Code[20])
        {
            Caption = 'Mfg Vendor';
        }
        field(50011; "Asset Loc-City"; Text[30])
        {
            Caption = 'Asset Loc-City';
        }
        field(50012; "Tagged In Book"; Boolean)
        {
            Caption = 'Tagged In Book';
        }
        field(50013; "Project Code(Budget#)"; Code[10])
        {
            Caption = 'Project Code(Budget#)';
        }
        field(50014; "Budget$"; Decimal)
        {
            Caption = 'Budget$';
        }
        field(50015; "Work Center"; Code[20])
        {
            Caption = 'Work Center';
            TableRelation = "Work Center";
        }
    }
}

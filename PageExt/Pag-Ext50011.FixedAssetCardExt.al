pageextension 50011 "Fixed Asset Card Ext" extends "Fixed Asset Card"
{
    layout
    {
        addafter("Last Date Modified")
        {
            field("Asset(Tag) No."; Rec."Asset(Tag) No.")
            {
                ApplicationArea = FixedAssets;
            }
            field("Property Tax"; Rec."Property Tax")
            {
                ApplicationArea = FixedAssets;
            }
            field("Purchase Order No."; Rec."Purchase Order No.")
            {
                ApplicationArea = FixedAssets;
            }
            field("Custodian"; Rec."Custodian")
            {
                ApplicationArea = FixedAssets;
            }
            field("Current Year"; Rec."Current Year")
            {
                ApplicationArea = FixedAssets;
            }
            field("Alpha Code"; Rec."Alpha Code")
            {
                ApplicationArea = FixedAssets;
            }
            field("Numeric Code"; Rec."Numeric Code")
            {
                ApplicationArea = FixedAssets;
            }
            field("Tool/Budget#"; Rec."Tool/Budget#")
            {
                ApplicationArea = FixedAssets;
            }
            field("Asset Loc-St"; Rec."Asset Loc-St")
            {
                ApplicationArea = FixedAssets;
            }
            field("Mfg Vendor"; Rec."Mfg Vendor")
            {
                ApplicationArea = FixedAssets;
            }
            field("Asset Loc-City"; Rec."Asset Loc-City")
            {
                ApplicationArea = FixedAssets;
            }
            field("Tagged In Book"; Rec."Tagged In Book")
            {
                ApplicationArea = FixedAssets;
            }
            field("Project Code(Budget#)"; Rec."Project Code(Budget#)")
            {
                ApplicationArea = FixedAssets;
            }
            field("Budget$"; Rec."Budget$")
            {
                ApplicationArea = FixedAssets;
            }
            field("Work Center"; Rec."Work Center")
            {
                ApplicationArea = FixedAssets;
            }
        }
    }
}

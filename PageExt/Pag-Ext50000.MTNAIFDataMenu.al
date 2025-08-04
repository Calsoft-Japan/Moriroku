pageextension 50000 "MTNA IF Data Menu" extends "Administrator Main Role Center"
{
    //CS 2024/8/13 Page Ext for MTNA IF Data Menu
    actions
    {
        addafter(Group15)
        {
            group("MTNA IF Data")
            {
                action("Email Notification")
                {
                    ApplicationArea = All;
                    RunObject = page "MTNA IF Email Notification";
                }
                action("Output Journal")
                {
                    ApplicationArea = All;
                    RunObject = page "MTNA_IF_OutputJournal";
                }
                action("Purchase Orders")
                {
                    ApplicationArea = All;
                    RunObject = page MTNA_IF_POHeaders;
                }
                action("Production Orders")
                {
                    ApplicationArea = All;
                    RunObject = page MTNA_IF_ProductionOrder;
                }
                action("Purchase Receiving")
                {
                    ApplicationArea = All;
                    RunObject = page MTNA_IF_PurchaseReceiving;
                }
                action("Standard Cost")
                {
                    ApplicationArea = All;
                    RunObject = page MTNA_IF_StandardCost;
                }
                action("Item Journal")
                {
                    ApplicationArea = All;
                    RunObject = page "MTNA_IF_ItemJournal";
                }
                action("Item Reclass Journal")
                {
                    ApplicationArea = All;
                    RunObject = page "MTNA_IF_ItemReclassJournal";
                }
            }
        }
    }
}

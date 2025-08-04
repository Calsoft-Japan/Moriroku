query 50000 "COGS Allocation VE Query"
{
    Caption = 'COGS Allocation VE Query';
    QueryType = Normal;
    UsageCategory = ReportsAndAnalysis;// Category to show the query under in Tell Me (search) and in role explorer under Report and Analysis. Available from version 23
    OrderBy = ascending(Item_No_);

    elements
    {
        dataitem(ValueEntry; "Value Entry")
        {
            //DataItemTableFilter = "Document Type" = filter("Document Type"::"Sales Invoice" | "Document Type"::"Sales Credit Memo"), "Item Ledger Entry Type" = filter("Item Ledger Entry Type"::Sale);
            column(CostAmountActual_A; "Cost Amount (Actual)")
            {
                Method = Sum;
            }

            filter(Global_Dimension_1_Code; "Global Dimension 1 Code") { }
            filter(Gen__Bus__Posting_Group; "Gen. Bus. Posting Group") { }
            filter(PostingDate; "Posting Date") { }
            filter(Document_Type; "Document Type") { }
            filter(Item_Ledger_Entry_Type; "Item Ledger Entry Type") { }
            dataitem(Item_; Item)
            {
                DataItemLink = "No." = ValueEntry."Item No.";
                SqlJoinType = InnerJoin;
                DataItemTableFilter = "Costing Method" = filter("Costing Method"::Standard), "Replenishment System" = filter("Replenishment System"::"Prod. Order");

                column(Item_No_; "No.")
                { }

                /* dataitem(BOM_Cost_shares_Calculated_Parent; "BOM Cost shares Calculated")
                {
                    DataItemLink = "No." = ValueEntry."Item No.";
                    SqlJoinType = InnerJoin;
                    DataItemTableFilter = Indentation = const(0);

                    column(Total_Cost_P; "Total Cost")
                    {
                    }
                } */

            }
        }
    }

    var
        gStarDate: Date;
        gEndDate: Date;
        gDepartment: Code[20];
        gEntryType: Option Sales,Scrap,Adjustment,Revalue;

    trigger OnBeforeOpen()
    begin
        if not ((gStarDate = 0D) and (gEndDate = 0D)) then
            SetRange(PostingDate, gStarDate, gEndDate);

        if gDepartment <> '' then
            SetRange(Global_Dimension_1_Code, gDepartment);

        case gEntryType of
            gEntryType::Sales:
                begin
                    SetFilter(Document_Type, '%1|%2', Enum::"Item Ledger Document Type"::"Sales Invoice", Enum::"Item Ledger Document Type"::"Sales Credit Memo");
                    SetRange(Item_Ledger_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                end;
            gEntryType::Scrap:
                begin
                    SetFilter(Item_Ledger_Entry_Type, '%1|%2', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", Enum::"Item Ledger Entry Type"::"Negative Adjmt.");
                    SetRange(Gen__Bus__Posting_Group, 'SCRAP');
                end;
            gEntryType::Adjustment:
                begin
                    SetFilter(Item_Ledger_Entry_Type, '%1|%2', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", Enum::"Item Ledger Entry Type"::"Negative Adjmt.");
                    SetFilter(Gen__Bus__Posting_Group, '<>%1 & <>%2 & <>%3', 'SCRAP', 'REVALUE', 'VENDOR');//SetFilter(Gen__Bus__Posting_Group, '<>%1', 'SCRAP|REVALUE');
                    //SetFilter(Gen__Bus__Posting_Group, '<>%1', 'SCRAP');
                end;
            gEntryType::Revalue:
                begin
                    SetFilter(Item_Ledger_Entry_Type, '%1|%2', Enum::"Item Ledger Entry Type"::"Positive Adjmt.", Enum::"Item Ledger Entry Type"::"Negative Adjmt.");
                    SetRange(Gen__Bus__Posting_Group, 'REVALUE');
                end;
        end;

        /* SetRange(PostingDate, 20241101D, 20241130D);
        SetRange(Global_Dimension_1_Code, '100');
        SetFilter(Item_Ledger_Entry_Type, '%1|%2', VE."Item Ledger Entry Type"::"Positive Adjmt.", VE."Item Ledger Entry Type"::"Negative Adjmt.");
        SetFilter(Gen__Bus__Posting_Group, '<>%1', 'SCRAP'); */
    end;

    procedure SetQueryFilter(StarDate: Date; EndDate: Date; Department: Code[20]; EntryType: Option Sales,Scrap,Adjustment)
    begin
        gStarDate := StarDate;
        gEndDate := EndDate;
        gDepartment := Department;
        gEntryType := EntryType;
    end;
}

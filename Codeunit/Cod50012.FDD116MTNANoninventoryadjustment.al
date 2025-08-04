codeunit 50012 "MTNA Non-inventory adjustment"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", OnBeforeCode, '', false, false)]
    local procedure "Item Jnl.-Post_OnBeforeCode"(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean; var SuppressCommit: Boolean; var IsHandled: Boolean)
    begin
        if (ItemJournalLine."Journal Template Name" = 'ITEM') and (ItemJournalLine."Journal Batch Name" = 'Z-EXPENSE') then
            HideDialog := true;
    end;


    trigger OnRun()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJnl: Record "Item Journal Line";
        ItmJnlBatch: Record "Item Journal Batch";
        Itm: Record Item;
        NoSeries: Codeunit "No. Series";
        JnlDocNo: Code[20];
        ItmJnlPost: Codeunit "Item Jnl.-Post";
        LineNo: Integer;
    begin
        ItmJnlBatch.Get('ITEM', 'Z-EXPENSE');
        JnlDocNo := NoSeries.PeekNextNo(ItmJnlBatch."No. Series", ItemLedgerEntry."Posting Date");// GetNextNo

        ItemJnl.Reset();
        ItemJnl."Journal Template Name" := 'ITEM';
        ItemJnl."Journal Batch Name" := 'Z-EXPENSE';
        if ItemJnl.FindSet() then
            ItemJnl.DeleteAll();

        LineNo := 0;

        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Location Code", 'Z-EXPENSE');
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>0');
        //ItemLedgerEntry.SetAscending("Posting Date", true);
        if ItemLedgerEntry.FindFirst() then begin
            repeat
                Itm.Get(ItemLedgerEntry."Item No.");

                LineNo += 10000;
                ItemJnl.Init();
                ItemJnl."Journal Template Name" := 'ITEM';
                ItemJnl."Journal Batch Name" := 'Z-EXPENSE';
                ItemJnl."Gen. Bus. Posting Group" := 'VENDOR';
                ItemJnl."Line No." := LineNo;
                ItemJnl."Posting Date" := ItemLedgerEntry."Posting Date";
                ItemJnl."Entry Type" := ItemJnl."Entry Type"::"Negative Adjmt.";
                ItemJnl."Document No." := JnlDocNo;
                ItemJnl."Item No." := ItemLedgerEntry."Item No.";
                ItemJnl."Location Code" := 'Z-EXPENSE';
                ItemJnl."Unit of Measure Code" := Itm."Base Unit of Measure";//ItemLedgerEntry."Unit of Measure Code";
                ItemJnl.Quantity := ItemLedgerEntry."Remaining Quantity";
                //ItemJnl."Quantity" := ItemLedgerEntry."Remaining Quantity" / ItemLedgerEntry."Qty. per Unit of Measure";//"Quantity (Base)" 
                ItemJnl."Shortcut Dimension 1 Code" := ItemLedgerEntry."Global Dimension 1 Code";
                ItemJnl."Shortcut Dimension 1 Code" := ItemLedgerEntry."Global Dimension 2 Code";
                ItemJnl."Applies-to Entry" := ItemLedgerEntry."Entry No.";
                //ItemJnl."Document No." := Format(ItemLedgerEntry."Entry No.");
                ItemJnl."Gen. Prod. Posting Group" := Itm."Gen. Prod. Posting Group";
                ItemJnl."Unit Amount" := 0;

                ItemJnl.Validate("Entry Type", ItemJnl."Entry Type"::"Negative Adjmt.");
                ItemJnl.Validate("Posting Date", ItemLedgerEntry."Posting Date");
                ItemJnl.Validate("Item No.", ItemLedgerEntry."Item No.");
                ItemJnl.Validate("Location Code", 'Z-EXPENSE');
                ItemJnl.Validate("Unit of Measure Code", Itm."Base Unit of Measure");//ItemLedgerEntry."Unit of Measure Code");
                ItemJnl.Validate("Quantity", ItemLedgerEntry."Remaining Quantity");
                //ItemJnl.Validate("Quantity", ItemLedgerEntry."Remaining Quantity" / ItemLedgerEntry."Qty. per Unit of Measure");
                ItemJnl.Validate("Unit Amount", 0);
                ItemJnl.Validate("Gen. Bus. Posting Group", 'VENDOR');
                ItemJnl.Validate("Gen. Prod. Posting Group", Itm."Gen. Prod. Posting Group");
                ItemJnl.Validate("Shortcut Dimension 1 Code", ItemLedgerEntry."Global Dimension 1 Code");
                ItemJnl.Validate("Shortcut Dimension 2 Code", ItemLedgerEntry."Global Dimension 2 Code");
                ItemJnl.Validate("Applies-to Entry", ItemLedgerEntry."Entry No.");
                ItemJnl.Insert();
            until ItemLedgerEntry.Next() = 0;

            ItemJnl.Reset();
            ItemJnl.SetRange("Journal Template Name", 'ITEM');
            ItemJnl.SetRange("Journal Batch Name", 'Z-EXPENSE');
            ItemJnl.SetRange("Gen. Bus. Posting Group", 'VENDOR');
            if ItemJnl.FindSet() then
                ItmJnlPost.Run(ItemJnl);
        end;
    end;

}

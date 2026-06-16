codeunit 50011 FDD114StdCostWorkSheet
{
    [EventSubscriber(ObjectType::Report, Report::"Implement Standard Cost Change", OnInsertRevalItemJnlLineOnBeforeItemJnlLineLoop, '', false, false)]
    local procedure "Implement Standard Cost Change_OnInsertRevalItemJnlLineOnBeforeItemJnlLineLoop"(var ItemJournalLine: Record "Item Journal Line"; var RevalJnlCreated: Boolean; var IsHandled: Boolean)
    var
        LineNo: Integer;
        JnlTempName: Code[10];
        JnlBatchName: Code[10];
    begin
        LineNo := ItemJournalLine."Line No.";
        if ItemJournalLine.Next() <> 0 then begin
            JnlTempName := ItemJournalLine."Journal Template Name";
            JnlBatchName := ItemJournalLine."Journal Batch Name";
            repeat
                ItemJournalLine.Validate("Gen. Bus. Posting Group", 'REVALUE');
                ItemJournalLine."Gen. Bus. Posting Group" := 'REVALUE';
                ItemJournalLine.Modify(true);
            until ItemJournalLine.Next() = 0;

            Clear(ItemJournalLine);
            ItemJournalLine.Reset();
            ItemJournalLine.SetRange("Journal Template Name", JnlTempName);
            ItemJournalLine.SetRange("Journal Batch Name", JnlBatchName);
            if LineNo > 0 then begin
                ItemJournalLine.SetRange("Line No.", LineNo);
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory Value", OnAfterInitItemJnlLine, '', false, false)]
    local procedure "Calculate Inventory Value_OnAfterInitItemJnlLine"(var ItemJournalLine: Record "Item Journal Line"; ItemJnlBatch: Record "Item Journal Batch")
    begin
        //ItemJournalLine.Validate("Gen. Bus. Posting Group", 'REVALUE');
        //ItemJournalLine."Gen. Bus. Posting Group" := 'REVALUE';
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory Value", OnAfterInsertItemJnlLine, '', false, false)]
    local procedure "Calculate Inventory Value_OnAfterInsertItemJnlLine"(var ItemJournalLine: Record "Item Journal Line"; EntryType2: Enum "Item Ledger Entry Type"; ItemNo2: Code[20]; VariantCode2: Code[10]; LocationCode2: Code[10]; Quantity2: Decimal; Amount2: Decimal; ApplyToEntry2: Integer; AppliedAmount: Decimal; CalcBase: Enum "Inventory Value Calc. Base")
    begin
        //ItemJournalLine.Validate("Gen. Bus. Posting Group", 'REVALUE');
        //ItemJournalLine."Gen. Bus. Posting Group" := 'REVALUE';
        //ItemJournalLine.Modify();
    end;


}

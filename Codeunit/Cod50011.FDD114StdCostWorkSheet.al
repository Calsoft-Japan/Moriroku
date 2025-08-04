codeunit 50011 FDD114StdCostWorkSheet
{
    [EventSubscriber(ObjectType::Report, Report::"Implement Standard Cost Change", OnInsertRevalItemJnlLineOnBeforeItemJnlLineLoop, '', false, false)]
    local procedure "Implement Standard Cost Change_OnInsertRevalItemJnlLineOnBeforeItemJnlLineLoop"(var ItemJournalLine: Record "Item Journal Line"; var RevalJnlCreated: Boolean; var IsHandled: Boolean)
    var
        LineNo: Integer;
    begin
        LineNo := ItemJournalLine."Line No.";
        if ItemJournalLine.Next() <> 0 then begin
            repeat
                ItemJournalLine.Validate("Gen. Bus. Posting Group", 'REVALUE');
                ItemJournalLine."Gen. Bus. Posting Group" := 'REVALUE';
                ItemJournalLine.Modify(true);
            until ItemJournalLine.Next() = 0;

            if LineNo = 0 then
                ItemJournalLine.FindFirst() else
                repeat
                    ItemJournalLine.Next(-1);
                until LineNo = ItemJournalLine."Line No.";
        end;
    end;


    [EventSubscriber(ObjectType::Report, Report::"Calculate Inventory Value", OnAfterInitItemJnlLine, '', false, false)]
    local procedure "Calculate Inventory Value_OnAfterInitItemJnlLine"(var ItemJournalLine: Record "Item Journal Line"; ItemJnlBatch: Record "Item Journal Batch")
    begin
        //ItemJournalLine.Validate("Gen. Bus. Posting Group", 'REVALUE');
        //ItemJournalLine."Gen. Bus. Posting Group" := 'REVALUE';
    end;

}

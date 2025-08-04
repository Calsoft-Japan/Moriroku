codeunit 50013 FDD119BatchPostPO
{


    trigger OnRun()
    begin

    end;

    procedure PostPurchaseOrder(var PurHeader: Record "Purchase Header"): Boolean
    var
        PurPost: Codeunit "Purch.-Post";
        result: Boolean;
    begin
        ClearLastError();
        result := true;
        if not PurPost.Run(PurHeader) then
            result := false;

        exit(result);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnConfirmCurrencyFactorUpdateOnBeforeConfirm, '', false, false)]
    local procedure "Purchase Header_OnConfirmCurrencyFactorUpdateOnBeforeConfirm"(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean; var Confirmed: Boolean)
    begin
        IsHandled := true;
        Confirmed := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeUpdatePurchLinesByFieldNo, '', false, false)]
    local procedure "Purchase Header_OnBeforeUpdatePurchLinesByFieldNo"(var PurchaseHeader: Record "Purchase Header"; ChangedFieldNo: Integer; var AskQuestion: Boolean; var IsHandled: Boolean)
    var
        "Field": Record "Field";
    begin
        /* Field.SetRange(TableNo, Database::"Purchase Header");
        Field.SetRange("Field Caption", 'Currency Factor');
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        if Field.Find('-') then begin
            if Field."No." = ChangedFieldNo then AskQuestion := false;
        end; */

        if PurchaseHeader.FieldNo("Currency Factor") = ChangedFieldNo then
            AskQuestion := false;
    end;


}

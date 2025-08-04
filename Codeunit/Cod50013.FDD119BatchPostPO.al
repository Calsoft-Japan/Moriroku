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

}

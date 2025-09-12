tableextension 50020 PurchaseHeaderExt extends "Purchase Header"
{
    fields
    {
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            begin
                if (xRec.Status = xRec.Status::Released) and (Rec.Status = Rec.Status::Open) then
                    Rec.PerformManualRelease();
            end;
        }
    }
}

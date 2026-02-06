tableextension 50021 RoutingHeaderExt extends "Routing Header"
{
    fields
    {
        modify(Status)
        {
            trigger OnBeforeValidate()
            var
                RecRoutingLine: Record "Routing Line";
            begin
                if (Rec.Status = Rec.Status::Certified) then begin
                    RecRoutingLine.Reset();
                    RecRoutingLine.SetRange("Routing No.", Rec."No.");
                    RecRoutingLine.SetRange("Version Code", Rec."Version Nos.");
                    if not RecRoutingLine.IsEmpty() then begin
                        RecRoutingLine.FindSet();
                        repeat
                            if RecRoutingLine."Routing Link Code" = '' then begin
                                Error('Routing Link Code must be set.');
                            end;
                        until RecRoutingLine.Next() = 0;
                    end;
                end;
            end;
        }
    }
}

table 50000 "MTNA IF Email Notification"
{
    //CS 2024/8/13 Channing.Zhou FDD300 Table for MTNA IF Email Notification
    Caption = 'MTNA IF Email Notification';

    fields
    {
        field(1; "Plant"; Enum "MTNA IF Plant")
        {
            Caption = 'Plant';
            trigger OnValidate()
            begin
                if Rec.Plant = Rec.Plant::Nil then Error('Plant can not be empty!');
            end;
        }
        field(2; "E-Mail"; Text[100])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            begin
                ValidateEmail();
            end;
        }
    }
    keys
    {
        key(PK; "Plant")
        {
            Clustered = true;
        }
    }

    local procedure ValidateEmail()
    var
        MailManagement: Codeunit "Mail Management";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeValidateEmail(Rec, IsHandled, xRec);
        if IsHandled then
            exit;

        if "E-Mail" = '' then
            exit;
        MailManagement.CheckValidEmailAddresses("E-Mail");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateEmail(var RecMNTAIFEmailNotification: Record "MTNA IF Email Notification"; var IsHandled: Boolean; xRecMNTAIFEmailNotification: Record "MTNA IF Email Notification")
    begin
    end;

    /*trigger OnInsert()
    var
        MNTAIFEmailNotiRec: Record "MTNA IF Email Notification";
        "LastNo.": integer;
    begin
        "LastNo." := 0;
        if MNTAIFEmailNotiRec.FindLast() then begin
            "LastNo." := MNTAIFEmailNotiRec."No.";
        end;
        "LastNo." += 1;
        Rec."No." := "LastNo.";
    end;*/
}

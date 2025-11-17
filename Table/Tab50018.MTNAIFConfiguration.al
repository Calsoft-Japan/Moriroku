table 50018 "MTNA IF Configuration"
{
    //CS 2025/10/27 Channing.Zhou FDD300 Table for MTNA IF Configuration
    Caption = 'MTNA IF Configuration';

    fields
    {
        field(1; "Batch job"; Enum "MTNA IF Batch Job")
        {
            Caption = 'Batch job';
            trigger OnValidate()
            begin
                if Rec."Batch job" = Rec."Batch job"::Nil then Error('Batch job can not be empty!');
            end;
        }
        field(2; "Max. records to process"; Integer)
        {
            Caption = 'Max. records to process';
        }
        field(3; "Hours not to archive"; Integer)
        {
            Caption = 'Hours not to archive';
        }
    }
    keys
    {
        key(PK; "Batch job")
        {
            Clustered = true;
        }
    }
}

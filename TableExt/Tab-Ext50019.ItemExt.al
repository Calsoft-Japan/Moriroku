tableextension 50019 ItemExt extends Item
{
    fields
    {
        field(50000; "Exclude from Plan. Wksh."; Boolean)
        {
            Caption = 'Exclude from Plan. Wksh.';
            InitValue = false;
        }
        field(50001; "Exclude from Std. Cost Roll"; Boolean)
        {
            Caption = 'Exclude from Std. Cost Roll';
            InitValue = false;
        }
    }
}

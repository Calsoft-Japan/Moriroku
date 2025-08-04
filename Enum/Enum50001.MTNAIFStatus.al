Enum 50001 "MTNA IF Status"
{
    //CS 2024/8/13 Enum for MTNA IF Status
    Extensible = true;

    value(0; Ready)
    {
        Caption = 'Ready';
    }
    value(1; Completed)
    {
        Caption = 'Completed';
    }
    value(2; Error)
    {
        Caption = 'Error';
    }
    value(3; New)
    {
        Caption = 'New';
    }
}

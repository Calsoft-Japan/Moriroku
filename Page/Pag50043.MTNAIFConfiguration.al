page 50043 "MTNA IF Configuration"
{
    //CS 2025/10/27 Channing.Zhou FDD300 Page for MTNA IF Configuration
    ApplicationArea = All;
    Caption = 'MTNA IF Configuration';
    PageType = List;
    SourceTable = "MTNA IF Configuration";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Batch job"; Rec."Batch job")
                {
                }
                field("Max. records to process"; Rec."Max. records to process")
                {
                }
                field("Hours not to archive"; Rec."Hours not to archive")
                {
                }
            }
        }
    }
}

page 50000 "MTNA IF Email Notification"
{
    //CS 2024/8/13 Channing.Zhou FDD300 Page for MTNA IF Email Notification
    ApplicationArea = All;
    Caption = 'MTNA IF Email Notification';
    PageType = List;
    SourceTable = "MTNA IF Email Notification";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Plant; Rec.Plant)
                {

                }
                field("E-Mail"; Rec."E-Mail")
                {

                }
            }
        }
    }
}

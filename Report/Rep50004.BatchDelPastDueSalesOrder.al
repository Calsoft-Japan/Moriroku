report 50004 "Batch Del Past Due Sales Order"
{
    ApplicationArea = All;
    Caption = 'Batch Del Past Due Sales Order';
    UsageCategory = Tasks;
    ProcessingOnly = true;
    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = where("Document Type" = const("Document Type"::Order));
            trigger OnAfterGetRecord()
            var
                SalesLine: Record "Sales Line";
                SaleSetup: Record "Sales & Receivables Setup";
                DelDate: Date;
                DateFormu: Text;
            begin
                SaleSetup.Get();
                if Format(SaleSetup."Delete Past Due Orders") <> '' then begin
                    DateFormu := '-' + Format(SaleSetup."Delete Past Due Orders");
                    DelDate := CalcDate(DateFormu, Today);


                    SalesLine.Reset();
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                    SalesLine.SetFilter("Requested Delivery Date", '>%1', DelDate);
                    if not SalesLine.FindSet() then begin
                        SalesLine.SetRange("Requested Delivery Date");
                        SalesLine.SetFilter("Qty. Shipped Not Invoiced", '>0');
                        if not SalesLine.FindSet() then
                            SalesHeader.Delete(true);
                    end;

                end;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
}

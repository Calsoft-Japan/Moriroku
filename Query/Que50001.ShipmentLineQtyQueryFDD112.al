query 50001 ShipmentLineQtyQueryFDD112
{
    Caption = 'ShipmentLineQtyQueryFDD112';
    QueryType = Normal;
    UsageCategory = ReportsAndAnalysis;// Category to show the query under in Tell Me (search) and in role explorer under Report and Analysis. Available from version 23
    OrderBy = ascending(Order_No_, Order_Line_No_);

    elements
    {

        dataitem(SalesShipmentLine; "Sales Shipment Line")
        {
            DataItemTableFilter = Quantity = filter('<>0'), Type = filter('<>0'), "Qty. Shipped Not Invoiced" = filter('>0');
            column(Order_No_; "Order No.")
            { }
            column(Order_Line_No_; "Order Line No.")
            { }

            column(Quantity; Quantity)
            {
                Method = Sum;
            }

            dataitem(SalesShipmentHeader; "Sales Shipment Header")
            {
                DataItemLink = "No." = SalesShipmentLine."Document No.";
                SqlJoinType = InnerJoin;

                column(PackageTrackingNo; "Package Tracking No.")
                { }
            }
        }

    }

    trigger OnBeforeOpen()
    begin
        if gOrderNo <> '' then
            SetRange(Order_No_, gOrderNo);

        if gPackageTrackingNo <> '' then
            SetRange(PackageTrackingNo, gPackageTrackingNo);

        //SetRange(Order_Line_No_, gOrdLineNo);
    end;

    var
        gOrderNo: Code[20];
        gOrdLineNo: Integer;
        gPackageTrackingNo: Text[30];


    procedure SetQueryFilter(OrderNo: Code[20]; PackageTrackingNo: Text[30])
    begin
        gOrderNo := OrderNo;
        gPackageTrackingNo := PackageTrackingNo;
        //gOrdLineNo := OrdLineNo;
    end;
}

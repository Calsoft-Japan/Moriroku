codeunit 50003 MTNAIFPurchaseOrderProcess
{
    //CS 2024/9/3 Bobby.Ji FDD302 CodeUnit for MTNA IF Purchase Order Process
    trigger OnRun()
    var
        ErrorRecCount: Integer;
    begin
        if ProcessAllData(ErrorRecCount) then begin
        end;
    end;

    [TryFunction]
    procedure ProcessAllData(var ErrorRecCount: Integer)
    var
        RecMTNA_IF_POHeader: Record MTNA_IF_POHeaders;

    begin
        RecMTNA_IF_POHeader.Reset();
        RecMTNA_IF_POHeader.SetRange(Status, RecMTNA_IF_POHeader.Status::Ready);
        if RecMTNA_IF_POHeader.FindFirst() then begin
            ProcessPurchaseOrderData(RecMTNA_IF_POHeader, ErrorRecCount);
        end;
    end;

    [TryFunction]
    procedure ProcessPurchaseOrderData(var RecMTNA_IF_POHeader: Record MTNA_IF_POHeaders; var ErrorRecCount: Integer)
    var
        RecPOHeaderLine: Record "Purchase Header";
        RecPOLines: Record "Purchase Line";
        ErrorMessageText: Text;
        RecMTNA_IF_POLine: Record MTNA_IF_POLines;
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
        POHeaderNo: Code[20];
        RecItem: Record Item;
        RecItemUom: Record "Item Unit of Measure";
    begin
        ErrorRecCount := 0;
        if RecMTNA_IF_POHeader.FindFirst() then begin
            repeat
                if RecMTNA_IF_POHeader.Status = RecMTNA_IF_POHeader.Status::Ready then begin
                    RecMTNA_IF_POHeader."Process start datetime" := CurrentDateTime;

                    if InsertPurchaseHeader(RecMTNA_IF_POHeader, POHeaderNo) then begin
                        RecMTNA_IF_POHeader.Status := RecMTNA_IF_POHeader.Status::Completed;
                        RecMTNA_IF_POHeader.Modify();

                        RecMTNA_IF_POLine.Reset();
                        RecMTNA_IF_POLine.SetRange("Header Entry No.", RecMTNA_IF_POHeader."Entry No.");
                        if RecMTNA_IF_POLine.FindFirst() then begin
                            repeat
                                if (RecMTNA_IF_POLine.Type = RecMTNA_IF_POLine.Type::Item) then begin
                                    /*2025/6/3 Channing.Zhou Add logic to check if the Item No existed before checking the Item UOM.*/
                                    RecItem.Reset();
                                    RecItem.SetRange("No.", RecMTNA_IF_POLine."No.");
                                    if RecItem.IsEmpty() then begin
                                        ErrorMessageText := RecMTNA_IF_POHeader."Order ID" + ' Item No doesn''t exist.';
                                        POHeaderErrorMessage(RecMTNA_IF_POHeader, ErrorMessageText);
                                        POLinesErrorMessage(RecMTNA_IF_POLine, ErrorMessageText);
                                        ErrorRecCount += 1;
                                        PORollback(POHeaderNo);
                                        break;
                                    end;
                                    RecItemUom.Reset();
                                    RecItemUom.SetRange("Item No.", RecMTNA_IF_POLine."No.");
                                    RecItemUom.SetRange(Code, RecMTNA_IF_POLine."Unit of Measure Code");
                                    if RecItemUom.IsEmpty() then begin
                                        ErrorMessageText := RecMTNA_IF_POHeader."Order ID" + ' Unit of Measure Code no found.';
                                        POHeaderErrorMessage(RecMTNA_IF_POHeader, ErrorMessageText);
                                        POLinesErrorMessage(RecMTNA_IF_POLine, ErrorMessageText);
                                        ErrorRecCount += 1;
                                        PORollback(POHeaderNo);
                                        break;
                                    end;
                                end;
                                if InsertPurchaseLine(RecMTNA_IF_POLine, RecMTNA_IF_POHeader, POHeaderNo) then begin
                                    RecMTNA_IF_POLine.Status := RecMTNA_IF_POLine.Status::Completed;
                                    RecMTNA_IF_POLine.Modify();
                                end
                                else begin
                                    ErrorMessageText := GetLastErrorText();
                                    POHeaderErrorMessage(RecMTNA_IF_POHeader, ErrorMessageText);
                                    POLinesErrorMessage(RecMTNA_IF_POLine, ErrorMessageText);
                                    ErrorRecCount += 1;
                                    PORollback(POHeaderNo);
                                    break;
                                end;

                                RecMTNA_IF_POLine."Processed datetime" := CurrentDateTime;
                                RecMTNA_IF_POLine.Modify();
                            until RecMTNA_IF_POLine.Next() = 0;
                        end;
                    end
                    else begin
                        ErrorMessageText := GetLastErrorText();
                        POHeaderErrorMessage(RecMTNA_IF_POHeader, ErrorMessageText);
                        ErrorRecCount += 1;
                        PORollback(POHeaderNo);
                    end;
                    RecMTNA_IF_POHeader."Processed datetime" := CurrentDateTime;
                    RecMTNA_IF_POHeader.Modify();
                end;
            until RecMTNA_IF_POHeader.Next() = 0;
        end;
    end;

    [TryFunction]
    local procedure InsertPurchaseHeader(RecMTNA_IF_POHeader: Record MTNA_IF_POHeaders; var POHeaderNo: Code[20])
    var
        RecPOHeaderLine: Record "Purchase Header";
        TempDimensionSetEntry: record "Dimension Set Entry" temporary;
        GeneralLedgerSetup: record "General Ledger Setup";
    //NoSeriesMgt: Codeunit "No. Series";
    begin
        GeneralLedgerSetup.Get();
        RecPOHeaderLine.Reset();
        RecPOHeaderLine.Init();
        RecPOHeaderLine."Document Type" := RecPOHeaderLine."Document Type"::Order;
        RecPOHeaderLine.Validate("Buy-from Vendor No.", RecMTNA_IF_POHeader."Vendor No.");
        RecPOHeaderLine.TestNoSeries();
        //RecPOHeaderLine."No." := NoSeriesMgt.GetNextNo(RecPOHeaderLine.GetNoSeriesCode(), WorkDate());
        RecPOHeaderLine."No." := RecMTNA_IF_POHeader."Order ID";
        RecPOHeaderLine."Your Reference" := RecMTNA_IF_POHeader."Your Reference";
        RecPOHeaderLine.Validate("Order Date", RecMTNA_IF_POHeader."Order Date");
        RecPOHeaderLine.Validate("Payment Terms Code", RecPOHeaderLine."Payment Terms Code");
        RecPOHeaderLine.Validate("Shipment Method Code", RecMTNA_IF_POHeader."Shipment Method Code");
        RecPOHeaderLine.Validate("Location Code", RecMTNA_IF_POHeader."Location Code");
        TempDimensionSetEntry.Reset();
        TempDimensionSetEntry.DeleteAll();
        TempDimensionSetEntry.init;
        TempDimensionSetEntry."Dimension Code" := GeneralLedgerSetup."Shortcut Dimension 1 Code";
        TempDimensionSetEntry."Dimension Value Code" := RecMTNA_IF_POHeader."Shortcut Dimension 1 Code";
        TempDimensionSetEntry.Insert();
        RecPOHeaderLine."Shortcut Dimension 1 Code" := RecMTNA_IF_POHeader."Shortcut Dimension 1 Code";
        if (RecMTNA_IF_POHeader."Shortcut Dimension 2 Code" <> '') then begin
            TempDimensionSetEntry.init;
            TempDimensionSetEntry."Dimension Code" := GeneralLedgerSetup."Shortcut Dimension 2 Code";
            TempDimensionSetEntry."Dimension Value Code" := RecMTNA_IF_POHeader."Shortcut Dimension 2 Code";
            TempDimensionSetEntry.Insert();
            RecPOHeaderLine."Shortcut Dimension 2 Code" := RecMTNA_IF_POHeader."Shortcut Dimension 2 Code";
        end;
        RecPOHeaderLine."Dimension Set ID" := AddDimensions(RecPOHeaderLine."Dimension Set ID", TempDimensionSetEntry);

        RecPOHeaderLine.Validate("Currency Code", RecMTNA_IF_POHeader."Currency Code");
        RecPOHeaderLine.Validate("Gen. Bus. Posting Group", RecPOHeaderLine."Gen. Bus. Posting Group");
        RecPOHeaderLine.Status := RecPOHeaderLine.Status::Open;
        RecPOHeaderLine."Responsibility Center" := RecMTNA_IF_POHeader."Responsibility Center";
        RecPOHeaderLine."Requested Receipt Date" := RecMTNA_IF_POHeader."Requested Receipt Date";

        POHeaderNo := RecPOHeaderLine."No.";

        RecPOHeaderLine.Insert();

    end;

    [TryFunction]
    local procedure InsertPurchaseLine(RecMTNA_IF_POLines: Record "MTNA_IF_POLines"; RecMTNA_IF_POHeader: Record MTNA_IF_POHeaders; POHeaderNo: Code[20])
    var
        RecPOLine: Record "Purchase Line";
        TempDimensionSetEntry: record "Dimension Set Entry" temporary;
        GeneralLedgerSetup: record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();

        RecPOLine.Init();
        RecPOLine."Document Type" := RecPOLine."Document Type"::Order;
        RecPOLine."Document No." := POHeaderNo;
        RecPOLine."Buy-from Vendor No." := RecMTNA_IF_POHeader."Vendor No.";
        RecPOLine."Line No." := RecMTNA_IF_POLines."Line No.";
        RecPOLine.Validate(Type, RecMTNA_IF_POLines.Type);
        RecPOLine.Validate("No.", RecMTNA_IF_POLines."No.");
        RecPOLine.Validate("Location Code", RecMTNA_IF_POHeader."Location Code");
        RecPOLine.Validate(Description, RecMTNA_IF_POLines.Description);
        RecPOLine.Validate("Unit of Measure", RecMTNA_IF_POLines."Unit of Measure Code");
        RecPOLine.Validate(Quantity, RecMTNA_IF_POLines.Quantity);
        RecPOLine.Validate("Direct Unit Cost", RecMTNA_IF_POLines."Unit Price");

        TempDimensionSetEntry.DeleteAll();
        TempDimensionSetEntry.init;
        TempDimensionSetEntry."Dimension Code" := GeneralLedgerSetup."Shortcut Dimension 1 Code";
        TempDimensionSetEntry."Dimension Value Code" := RecMTNA_IF_POLines."Shortcut Dimension 1 Code";
        TempDimensionSetEntry.Insert();
        RecPOLine."Shortcut Dimension 1 Code" := RecMTNA_IF_POLines."Shortcut Dimension 1 Code";
        if (RecMTNA_IF_POLines."Shortcut Dimension 2 Code" <> '') then begin
            TempDimensionSetEntry.init;
            TempDimensionSetEntry."Dimension Code" := GeneralLedgerSetup."Shortcut Dimension 2 Code";
            TempDimensionSetEntry."Dimension Value Code" := RecMTNA_IF_POLines."Shortcut Dimension 2 Code";
            TempDimensionSetEntry.Insert();
            RecPOLine."Shortcut Dimension 2 Code" := RecMTNA_IF_POLines."Shortcut Dimension 2 Code";
        end;
        RecPOLine."Dimension Set ID" := AddDimensions(RecPOLine."Dimension Set ID", TempDimensionSetEntry);

        RecPOLine.Insert();
    end;


    procedure AddDimensions(VarDimenSetID: integer; var VarDimSetEntry: record "Dimension Set Entry" temporary) newDmSetID: integer;
    var
        DimTable: record "Dimension Set Entry";
        DimValue: record "Dimension Value";
        TmpDimTable: record "Dimension Set Entry" temporary;
        DimsetID: integer;
        DimMgtLocal: Codeunit "DimensionManagement";
        DimensionStr: text;
    BEGIN
        newDmSetID := VarDimenSetID;
        DimMgtLocal.GetDimensionSet(TmpDimTable, VarDimenSetID);
        VarDimSetEntry.RESET;
        IF VarDimSetEntry.FIND('-') THEN BEGIN
            REPEAT
                DimValue.RESET;
                DimValue.SETRANGE("Dimension Code", VarDimSetEntry."Dimension Code");
                DimValue.SETRANGE(Code, VarDimSetEntry."Dimension Value Code");
                IF NOT DimValue.FIND('-') THEN BEGIN
                    DimValue.INIT;
                    DimValue."Dimension Code" := VarDimSetEntry."Dimension Code";
                    DimValue.Code := VarDimSetEntry."Dimension Value Code";
                    DimValue.INSERT(TRUE);
                END;
                TmpDimTable.RESET;
                TmpDimTable.SETRANGE("Dimension Code", VarDimSetEntry."Dimension Code");
                IF TmpDimTable.FIND('-') THEN BEGIN
                    TmpDimTable.VALIDATE("Dimension Value Code", VarDimSetEntry."Dimension Value Code");
                    TmpDimTable.MODIFY(TRUE);
                END
                ELSE BEGIN
                    TmpDimTable.INIT;
                    TmpDimTable."Dimension Code" := VarDimSetEntry."Dimension Code";
                    TmpDimTable.VALIDATE("Dimension Value Code", VarDimSetEntry."Dimension Value Code");
                    TmpDimTable.INSERT(TRUE);
                END;
            UNTIL VarDimSetEntry.NEXT <= 0;
            newDmSetID := DimMgtLocal.GetDimensionSetID(TmpDimTable);
            Commit();
        END;
    END;

    [TryFunction]
    local procedure POHeaderErrorMessage(var RecMTNA_IF_POHeader: Record MTNA_IF_POHeaders; ErrorMessageText: Text)
    var
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
    begin
        RecMTNA_IF_POHeader.Status := RecMTNA_IF_POHeader.Status::Error;
        RecMTNA_IF_POHeader.SetErrormessage('Error occurred when inserting Purchase order header. The detailed error message is: ' + ErrorMessageText);
        RecMTNA_IF_POHeader.Modify();
        if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF POHeader Process Insert', RecMTNA_IF_POHeader.Plant, Format(RecMTNA_IF_POHeader."Entry No."),
            RecMTNA_IF_POHeader."Process start datetime", ErrorMessageText) then begin
        end;
    end;

    [TryFunction]
    local procedure POLinesErrorMessage(var RecMTNA_IF_POLines: Record MTNA_IF_POLines; ErrorMessageText: Text)
    var
        CuMTNAIFCommonProcess: CodeUnit "MTNA_IF_CommonProcess";
    begin
        RecMTNA_IF_POLines.Status := RecMTNA_IF_POLines.Status::Error;
        RecMTNA_IF_POLines.SetErrormessage('Error occurred when inserting Purchase order lines. The detailed error message is: ' + ErrorMessageText);
        RecMTNA_IF_POLines.Modify();
        if CuMTNAIFCommonProcess.SendNotificationEmail('MTNA IF POHeader Process Insert', RecMTNA_IF_POLines.Plant, Format(RecMTNA_IF_POLines."Entry No."),
            RecMTNA_IF_POLines."Process start datetime", ErrorMessageText) then begin
        end;
    end;

    [TryFunction]
    local procedure PORollback(POHeaderNo: Code[20])
    var
        RecPOHeader: Record "Purchase Header";
        RecPOLine: Record "Purchase Line";
    begin
        RecPOHeader.Reset();
        RecPOHeader.SetRange("No.", POHeaderNo);
        if RecPOHeader.FindFirst() then begin
            RecPOHeader.DeleteAll();
        end;

        RecPOLine.Reset();
        RecPOLine.SetRange("Document No.", POHeaderNo);
        if RecPOLine.FindFirst() then begin
            RecPOLine.DeleteAll();
        end;
    end;
}

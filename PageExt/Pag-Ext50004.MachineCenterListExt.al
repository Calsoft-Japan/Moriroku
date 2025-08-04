pageextension 50004 "Machine Center List Ext." extends "Machine Center List"
{
    actions
    {
        addafter("Calculate Machine Center Calendar")
        {
            action(ExportExcel)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Export Cost Rates';
                Image = ExportToExcel;

                trigger OnAction()
                begin
                    ExportToExcel();
                end;
            }

            action(ImportExcel)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Import Cost Rates';
                Image = ImportExcel;

                trigger OnAction()
                begin
                    ImportExcel();
                end;
            }
        }

        addafter("Ta&sk List_Promoted")
        {
            actionref(ExportToExcel; ExportExcel)
            {
            }

            actionref(ImportFromExcel; ImportExcel)
            {
            }
        }
    }

    procedure ExportToExcel()
    var
        //TempExcelBuff: Record "Excel Buffer" temporary;
        MCenter: Record "Machine Center";
    begin
        ExcelBuf.Reset();
        ExcelBuf.ClearNewRow;
        ExcelBuf.DeleteAll;
        ExcelBuf.AddColumn('No.', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);
        ExcelBuf.AddColumn('Direct Unit Cost', false, '', true, false, false, '', ExcelBuf."Cell Type"::Text);

        MCenter.Reset();
        if MCenter.FindFirst() then
            repeat
                ExcelBuf.NewRow;
                ExcelBuf.AddColumn(MCenter."No.", false, '', false, false, false, '', ExcelBuf."Cell Type"::Text);
                ExcelBuf.AddColumn(MCenter."Direct Unit Cost", false, '', false, false, false, '', ExcelBuf."Cell Type"::Number);
            until MCenter.Next() = 0;

        ExcelBuf.CreateNewBook('Machine Center');
        /*if (ExcelLayout(FicheroInStream)) then begin
            TempExcelBuff.OpenBookStream(FicheroInStream, 'Data');
        end;*/

        ExcelBuf.WriteSheet('Machine Center', CompanyName(), UserId());
        ExcelBuf.SetFriendlyFilename('Machine Center');
        ExcelBuf.CloseBook();
        ExcelBuf.OpenExcel();
    end;

    procedure ImportExcel()
    var
        PathFileName: Text;
        FileInStream: InStream;
        X: Integer;
        CellText: Text;
        CNo: Text;
        DCost: Text;
        DUnitCost: Decimal;
        MCenter: Record "Machine Center";
        Invalid: Text;
        ErrMsg: Text;
    begin
        if UploadIntoStream('select a excel file:', 'C:\TEMP', ' Excel file|*.xlsx', PathFileName, FileInStream) then begin
            sheetName := ExcelBuf.SelectSheetsNameStream(FileInStream);
            if SheetName = '' then
                exit;

            ExcelBuf.LOCKTABLE;
            ExcelBuf.DELETEALL;
            ExcelBuf.OpenBookStream(FileInStream, SheetName);
            ExcelBuf.SetReadDateTimeInUtcDate(true);
            ExcelBuf.ReadSheet;
        end
        else
            exit;

        if ExcelBuf.IsEmpty then Error('Nothing to Import. Plesae check the import file.');

        LogHeader();

        GetLastRowandColumn();
        FOR X := 2 TO TotalRows DO begin
            Clear(ErrMsg);
            Invalid := 'NO';
            CellText := GetValueAtCell(X, 1, 0);
            CNo := CellText;
            CellText := GetValueAtCell(X, 2, 0);
            DCost := CellText;

            MCenter.Reset();
            MCenter.SetRange("No.", CNo.Trim());
            if MCenter.FindFirst() then begin
                if Evaluate(DUnitCost, DCost.Trim()) then begin
                    MCenter.Validate("Direct Unit Cost", DUnitCost);
                    MCenter.Modify()
                end else begin
                    Invalid := 'YES';
                    ErrMsg := StrSubstNo('[%1] is not a valid Decimal.', DCost);
                end;
            end else begin
                Invalid := 'YES';
                ErrMsg := StrSubstNo('This Machine Center [%1] does not exist.', CNo);
            end;
            AddLogMessage(Invalid, CNo, DCost, ErrMsg);
        end;

        ShowLog();
    end;

    procedure GetValueAtCell(RowNo: Integer; ColNo: Integer; length: Integer): Text;
    var
        ExcelBuf1: Record "Excel Buffer" temporary;
    begin
        IF ExcelBuf.GET(RowNo, ColNo) THEN BEGIN
            IF length = 0 THEN
                EXIT(ExcelBuf."Cell Value as Text")
            ELSE
                EXIT(COPYSTR(ExcelBuf."Cell Value as Text", 1, length))

        END
        ELSE
            EXIT('');
    end;

    procedure GetLastRowandColumn();
    begin
        ExcelBuf.SETRANGE("Row No.", 1);
        TotalColumns := ExcelBuf.COUNT;

        ExcelBuf.RESET;
        IF ExcelBuf.FINDLAST THEN
            TotalRows := ExcelBuf."Row No.";
    end;

    procedure LogHeader()
    begin
        LogExcelBuf.Reset();
        LogExcelBuf.ClearNewRow;
        LogExcelBuf.DeleteAll;
        LogExcelBuf.AddColumn('Invalid', false, '', true, false, false, '', LogExcelBuf."Cell Type"::Text);
        LogExcelBuf.AddColumn('Message', false, '', true, false, false, '', LogExcelBuf."Cell Type"::Text);
        LogExcelBuf.AddColumn('No.', false, '', true, false, false, '', LogExcelBuf."Cell Type"::Text);
        LogExcelBuf.AddColumn('Direct Unit Cost', false, '', true, false, false, '', LogExcelBuf."Cell Type"::Text);
    end;

    procedure AddLogMessage(Invalid: Text; No: Text; DCost: Text; Msg: Text)
    begin
        LogExcelBuf.NewRow;
        LogExcelBuf.AddColumn(Invalid, false, '', false, false, false, '', LogExcelBuf."Cell Type"::Text);
        LogExcelBuf.AddColumn(Msg, false, '', false, false, false, '', LogExcelBuf."Cell Type"::Text);
        LogExcelBuf.AddColumn(No, false, '', false, false, false, '', LogExcelBuf."Cell Type"::Text);
        LogExcelBuf.AddColumn(DCost, false, '', false, false, false, '', LogExcelBuf."Cell Type"::Text);
    end;

    procedure ShowLog()
    begin
        LogExcelBuf.CreateNewBook('Machine Center Import Log');

        LogExcelBuf.WriteSheet('Machine Center Log', CompanyName(), UserId());
        LogExcelBuf.SetFriendlyFilename('Machine Center Log');
        LogExcelBuf.CloseBook();
        LogExcelBuf.OpenExcel();
    end;

    var
        ExcelBuf: Record "Excel Buffer" temporary;
        LogExcelBuf: Record "Excel Buffer" temporary;
        SheetName: Text[250];
        TotalColumns: Integer;
        TotalRows: Integer;

    local procedure ImportExcelFile()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;

        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";

        SheetName, ErrorMessage : Text;
        FileInStream: InStream;
        ImportFileLbl: Label 'Import file';
    begin
        // Select file and import the file to tempBlob
        FileManagement.BLOBImportWithFilter(TempBlob, ImportFileLbl, '', FileManagement.GetToFilterText('', '.xlsx'), 'xlsx');

        // Select sheet from the excel file
        TempBlob.CreateInStream(FileInStream);
        SheetName := TempExcelBuffer.SelectSheetsNameStream(FileInStream);

        // Open selected sheet
        TempBlob.CreateInStream(FileInStream);
        ErrorMessage := TempExcelBuffer.OpenBookStream(FileInStream, SheetName);
        if ErrorMessage <> '' then
            Error(ErrorMessage);

        TempExcelBuffer.ReadSheet();
        if Rec.FindSet() then
            repeat
                Message('%1, %2: %3', TempExcelBuffer."Row No.", TempExcelBuffer."Column No.", TempExcelBuffer."Cell Value as Text");
            until TempExcelBuffer.Next() < 1;
    end;
}

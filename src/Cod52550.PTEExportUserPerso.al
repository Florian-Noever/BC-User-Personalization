codeunit 52550 "PTE Export User Perso"
{
    procedure Export(UserIds: List of [Guid])
    var
        PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]];
        UserId: Guid;
        RecordList: List of [Dictionary of [Integer, Text]];
        Filename: Text;
        JsonText: Text;
    begin
        if UserIds.Count = 1 then begin
            Export(UserIds.Get(1));
            exit;
        end;

        foreach UserId in UserIds do begin
            RecordList := GetRecordList(UserId);
            PersoDict.Add(UserId, RecordList);
        end;

        JsonText := SerializeJson(PersoDict);

        Filename := 'UserPersonalization_MultipleUsers.json';
        SaveJson(JsonText, Filename);
    end;

    procedure Export(UserId: Guid)
    var
        User: Record User;
        PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]];
        RecordList: List of [Dictionary of [Integer, Text]];
        Filename: Text;
        JsonText: Text;
    begin
        User.SetLoadFields("User Name");
        User.Get(UserId);

        RecordList := GetRecordList(UserId);
        PersoDict.Add(UserId, RecordList);
        JsonText := SerializeJson(PersoDict);

        Filename := 'UserPersonalization_' + User."User Name" + '_' + Format(UserId) + '.json';
        SaveJson(JsonText, Filename);
    end;

    local procedure SaveJson(JsonText: Text; FileName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        SaveFileDialogFilterMsg: Label 'JSON Files (*.json)|*.json',
            Comment = 'de-DE=JSON-Dateien (*.json)|*.json';
        SaveFileDialogTitleMsg: Label 'Save JSON file',
            Comment = 'de-DE=JSON-Datei speichern';
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(JsonText);
        TempBlob.CreateInStream(InStr);
        DownloadFromStream(InStr, SaveFileDialogTitleMsg, '', SaveFileDialogFilterMsg, Filename);
    end;

    local procedure SerializeJson(PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]]): Text
    var
        UserId: Guid;
        UserPersoRoot: JsonObject;
        RecordList: List of [Dictionary of [Integer, Text]];
        JsonText: Text;
    begin
        foreach UserId in PersoDict.Keys() do begin
            PersoDict.Get(UserId, RecordList);
            UserPersoRoot.Add(UserId, BuildUserPersoArr(RecordList));
        end;

        UserPersoRoot.WriteTo(JsonText);
        exit(JsonText);
    end;

    local procedure BuildUserPersoArr(RecordList: List of [Dictionary of [Integer, Text]]): JsonArray
    var
        OneDict: Dictionary of [Integer, Text];
        PageNoKey: Integer;
        ItemsArr: JsonArray;
        DictObj: JsonObject;
        PageFieldValue: Text;
    begin
        foreach OneDict in RecordList do begin
            foreach PageNoKey in OneDict.Keys() do begin
                OneDict.Get(PageNoKey, PageFieldValue);
                DictObj.Add(Format(PageNoKey), PageFieldValue);
            end;
            ItemsArr.Add(DictObj);
            Clear(DictObj);
        end;
        exit(ItemsArr);
    end;

    local procedure GetRecordList(UserId: Guid): List of [Dictionary of [Integer, Text]]
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        RecordList: List of [Dictionary of [Integer, Text]];
    begin
        RecRef.Open(Database::"User Page Metadata", false, CompanyName());
        FldRef := RecRef.Field(1);
        FldRef.SetRange(UserId);
        if RecRef.FindSet() then
            repeat
                RecordList.Add(GetFieldValues(RecRef));
            until RecRef.Next() = 0;
        RecRef.Close();
        exit(RecordList);
    end;

    local procedure GetFieldValues(var RecRef: RecordRef): Dictionary of [Integer, Text]
    var
        FldRef: FieldRef;
        FieldValuesDict: Dictionary of [Integer, Text];
        I: Integer;
        ValueTxt: Text;
    begin
        for I := 1 to RecRef.FieldCount() do begin
            FldRef := RecRef.FieldIndex(I);

            // Resolve FlowFields, if any
            if FldRef.Class = FldRef.Class::FlowField then
                FldRef.CalcField();

            // Resolve BLOBs to text (if needed)
            case FldRef.Type of
                FldRef.Type::Blob:
                    ValueTxt := ExportBlob(FldRef);
                else
                    ValueTxt := Format(FldRef);
            end;

            FieldValuesDict.Add(FldRef.Number(), ValueTxt);
        end;
        exit(FieldValuesDict);
    end;

    local procedure ExportBlob(FldRef: FieldRef): Text
    var
        TempBlob: Codeunit "Temp Blob";
        Instr: InStream;
        FullText: Text;
        TempLine: Text;
    begin
        Clear(TempBlob);
        TempBlob.FromFieldRef(FldRef);
        if not TempBlob.HasValue() then
            exit('');
        TempBlob.CreateInStream(Instr, TextEncoding::UTF8);
        while not InStr.EOS do begin
            InStr.ReadText(TempLine, 1024);
            FullText += TempLine;
        end;
        exit(FullText);
    end;
}

codeunit 52551 "PTE Import User Perso"
{
    procedure Import()
    begin
        Import(UserSecurityId());
    end;

    procedure Import(UserId: Guid);
    var
        TempBlob: Codeunit "Temp Blob";
        PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]];
        InStr: InStream;
        JsonParseErrorLbl: Label 'Error parsing JSON file.',
            Comment = 'de-DE=Fehler beim Parsen der JSON-Datei.';
        FromFile: Text;
        FullText, TempLine : Text;
    begin
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        UploadIntoStream('', '', '', FromFile, InStr);
        while not InStr.EOS() do begin
            InStr.ReadText(TempLine, 1024);
            FullText += TempLine;
        end;
        if not TryParseJson(FullText, PersoDict) then
            Error(JsonParseErrorLbl);

        WriteUserPersoDict(UserId, PersoDict);
    end;

    procedure ImportPersoDict(PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]])
    begin
        ImportPersoDict(UserSecurityId(), PersoDict);
    end;

    procedure ImportPersoDict(UserId: Guid; PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]])
    begin
        WriteUserPersoDict(UserId, PersoDict);
    end;

    procedure RetrievePersoDict(): Dictionary of [Guid, List of [Dictionary of [Integer, Text]]]
    var
        TempBlob: Codeunit "Temp Blob";
        PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]];
        InStr: InStream;
        FromFile: Text;
        FullText, TempLine : Text;
    begin
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        UploadIntoStream('', '', '', FromFile, InStr);
        while not InStr.EOS() do begin
            InStr.ReadText(TempLine, 1024);
            FullText += TempLine;
        end;
        if TryParseJson(FullText, PersoDict) then
            exit(PersoDict);
    end;

    local procedure TryParseJson(JsonText: Text; var PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]]): Boolean
    var
        OneDict: Dictionary of [Integer, Text];
        UserId: Guid;
        DictPageNo: Integer;
        I: Integer;
        RootObj: JsonObject;
        PageValueToken: JsonToken;
        UserPersoItemsArrToken: JsonToken;
        UserPersoItemToken: JsonToken;
        RecordList: List of [Dictionary of [Integer, Text]];
        PageNoKey: Text;
        RootUserIdKey: Text;
    begin
        if not RootObj.ReadFrom(JsonText) then
            exit(false);

        foreach RootUserIdKey in RootObj.Keys() do begin
            if RootObj.Get(RootUserIdKey, UserPersoItemsArrToken) and UserPersoItemsArrToken.IsArray() then
                for I := 0 to UserPersoItemsArrToken.AsArray().Count() do
                    if UserPersoItemsArrToken.AsArray().Get(I, UserPersoItemToken) and UserPersoItemToken.IsObject() then begin
                        foreach PageNoKey in UserPersoItemToken.AsObject().Keys() do
                            if UserPersoItemToken.AsObject().Get(PageNoKey, PageValueToken) and PageValueToken.IsValue() and Evaluate(DictPageNo, PageNoKey) then
                                OneDict.Add(DictPageNo, PageValueToken.AsValue().AsText());
                        RecordList.Add(OneDict);
                        Clear(OneDict);
                    end;
            if Evaluate(UserId, RootUserIdKey) then begin
                PersoDict.Add(UserId, RecordList);
                Clear(RecordList);
            end;
        end;

        exit(true);
    end;

    local procedure WriteUserPersoDict(UserId: Guid; PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]])
    var
        UserIdKey: Guid;
        RecordList: List of [Dictionary of [Integer, Text]];
    begin
        foreach UserIdKey in PersoDict.Keys() do begin
            PersoDict.Get(UserIdKey, RecordList);
            WriteRecordList(UserId, RecordList);
        end;
    end;

    local procedure WriteRecordList(UserId: Guid; RecordList: List of [Dictionary of [Integer, Text]])
    var
        RecRef: RecordRef;
        OverwriteAnswered: Boolean;
        OverwriteEnabled: Boolean;
        OverwriteNeeded: Boolean;
        FieldValuesDict: Dictionary of [Integer, Text];
        OverWriteErrorLbl: Label 'Some Personalizations already exist for this user. Do you want to overwrite them?',
            Comment = 'de-DE=Für diesen Benutzer existieren bereits Personalisierungen. Möchten Sie diese überschreiben?';
    begin
        RecRef.Open(Database::"User Page Metadata", false, CompanyName());
        foreach FieldValuesDict in RecordList do begin
            OverwriteNeeded := not WriteFieldValues(UserId, RecRef, FieldValuesDict);

            if OverwriteNeeded and not OverwriteAnswered then begin
                OverwriteEnabled := Confirm(OverWriteErrorLbl);
                OverwriteAnswered := true;
            end;

            if OverwriteNeeded and OverwriteEnabled then
                RecRef.Modify(true);
            OverwriteNeeded := false;
        end;
        RecRef.Close();
    end;

    local procedure WriteFieldValues(UserId: Guid; var RecRef: RecordRef; FieldValuesDict: Dictionary of [Integer, Text]) Success: Boolean
    var
        FldRef: FieldRef;
        HasChanges: Boolean;
        FieldNo: Integer;
        ValueTxt: Text;
    begin
        RecRef.Init();
        foreach FieldNo in FieldValuesDict.Keys do begin
            FldRef := RecRef.Field(FieldNo);
            ValueTxt := FieldValuesDict.Get(FieldNo);

            if FldRef.Class <> FldRef.Class::FlowField then
                case FldRef.Type of
                    FldRef.Type::Blob:
                        begin
                            ImportBlob(FldRef, ValueTxt);
                            HasChanges := true;
                        end;
                    FldRef.Type::Guid:
                        if FldRef.Number = 1 then begin
                            FldRef.Value := UserId;
                            HasChanges := true;
                        end;
                    else
                        if Evaluate(FldRef, ValueTxt) then
                            HasChanges := true;
                end;
        end;
        Success := not HasChanges;
        if HasChanges then
            Success := RecRef.Insert(true);
    end;

    local procedure ImportBlob(var FldRef: FieldRef; FldValue: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(FldValue);
        TempBlob.ToFieldRef(FldRef);
    end;
}

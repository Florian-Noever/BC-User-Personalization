table 52550 "PTE User Perso Visualizer Temp"
{
    Caption = 'User Personalization Visualizer',
        Comment = 'de-DE=Benutzerpersonalisierungs-Visualizer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User ID',
                Comment = 'de-DE=Benutzer-ID';
            Editable = false;
            TableRelation = User;
        }
        field(2; "Page ID"; Integer)
        {
            Caption = 'Page ID',
                Comment = 'de-DE=Seiten-ID';
            Editable = false;
            TableRelation = "Page Metadata";
        }
        field(10; "Page Caption"; Text[80])
        {
            CalcFormula = lookup("Page Metadata"."Caption" where(ID = field("Page ID")));
            Caption = 'Page Caption',
                Comment = 'de-DE=Seitenbeschriftung';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Do Import"; Boolean)
        {
            Caption = 'Do Import',
                Comment = 'de-DE=Importieren';
            InitValue = true;
        }
    }
    keys
    {
        key(PK; "User Security ID", "Page ID")
        {
            Clustered = true;
        }
    }

    var
        PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]];

    procedure GetPersoDict(): Dictionary of [Guid, List of [Dictionary of [Integer, Text]]]
    var
        I: Integer;
        RecordList: List of [Dictionary of [Integer, Text]];
        Position, View : Text;
    begin
        Position := Rec.GetPosition();
        View := Rec.GetView();
        ClearViewKeepGlobals();
        if Rec.FindSet() then
            repeat
                if PersoDict.Get("User Security ID", RecordList) then begin
                    for I := 1 to RecordList.Count do
                        FindAndRemovePage(Rec."Page ID", Rec, RecordList);
                    if RecordList.Count = 0 then
                        PersoDict.Remove("User Security ID")
                end;
            until Next() = 0;
        if View <> '' then
            Rec.SetView(View);
        if Position <> '' then
            Rec.SetPosition(Position);
        exit(PersoDict);
    end;

    local procedure FindAndRemovePage(PageNo: Integer; var CurrRec: Record "PTE User Perso Visualizer Temp"; var RecordList: List of [Dictionary of [Integer, Text]]): Boolean
    var
        I: Integer;
    begin
        for I := 1 to RecordList.Count do
            if Evaluate(PageNo, RecordList.Get(I).Get(2)) then begin
                if (PageNo = CurrRec."Page ID") and not "Do Import" then begin
                    RecordList.RemoveAt(I);
                    exit(true);
                end;
            end else begin
                RecordList.RemoveAt(I);
                exit(true);
            end;
    end;

    procedure SetPersoDict(NewPersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]])
    var
        ItemsDict: Dictionary of [Integer, Text];
        UserId: Guid;
        PageNo: Integer;
        RecordList: List of [Dictionary of [Integer, Text]];
        UserIdKey: Text;
    begin
        PersoDict := NewPersoDict;
        Rec.DeleteAll();
        foreach UserIdKey in PersoDict.Keys() do
            if Evaluate(UserId, UserIdKey) then begin
                RecordList := PersoDict.Get(UserId);
                foreach ItemsDict in RecordList do
                    if Evaluate(PageNo, ItemsDict.Get(2)) then begin
                        Rec.Init();
                        "User Security ID" := UserId;
                        "Page ID" := PageNo;
                        Rec.Insert(true);
                    end;
                Clear(RecordList);
            end;
    end;

    local procedure ClearViewKeepGlobals()
    begin
        Rec.SetView('');          // clear filters + set key/order
        Rec.ClearMarks();         // remove marks
        Rec.MarkedOnly(false);    // ensure MarkedOnly is off
        Rec.SetLoadFields();      // revert to default load fields
    end;
}
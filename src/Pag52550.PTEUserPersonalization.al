page 52550 "PTE User Personalization"
{
    AdditionalSearchTerms = 'Extend User Personalization,Extended User Personalization,User Personalization', Locked = true;
    ApplicationArea = All;
    Caption = 'Extended User Personalization',
        Comment = 'de-DE=Erweiterte Benutzerpersonalisierung';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = User;
    SourceTableView = where(State = filter(Enabled));
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("User Security ID"; Rec."User Security ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the User Security Identifier (SID) of the user that is logged on to the current session.',
                        Comment = 'de-DE= Gibt die Sicherheits-ID (SID) des Benutzers an, der bei der aktuellen Sitzung angemeldet ist.';
                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the name of the user that is logged on to the current session.',
                        Comment = 'de-DE= Gibt den Namen des Benutzers an, der bei der aktuellen Sitzung angemeldet ist.';
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the full name of the user that is logged on to the current session.',
                        Comment = 'de-DE= Gibt den vollständigen Namen des Benutzers an, der bei der aktuellen Sitzung angemeldet ist.';
                }
                field(Download; DownloadLbl)
                {
                    ApplicationArea = All;
                    CaptionClass = DownloadLbl;
                    Editable = false;
                    ToolTip = 'Downloads the user personalization settings for the selected user.',
                        Comment = 'de-DE=Lädt die Benutzereinstellungen für den ausgewählten Benutzer herunter.';

                    trigger OnDrillDown()
                    var
                        ExportUserPerso: Codeunit "PTE Export User Perso";
                    begin
                        ExportUserPerso.Export(Rec."User Security ID");
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Import)
            {
                ApplicationArea = All;
                Caption = 'Import',
                    Comment = 'de-DE=Importieren';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Imports user personalization settings from a JSON file.',
                    Comment = 'de-DE=Importiert Benutzereinstellungen aus einer JSON Datei.';

                trigger OnAction()
                var
                    TempUserPersoVisualizer: Record "PTE User Perso Visualizer Temp";
                    User: Record User;
                    ImportUserPerso: Codeunit "PTE Import User Perso";
                    PersoDict: Dictionary of [Guid, List of [Dictionary of [Integer, Text]]];
                    UserSelectionLbl: Label 'Do you want to replace the current user personalizations or a different user''s?',
                        Comment = 'de-DE=Möchten Sie die aktuellen Benutzerpersonalisierungen oder die eines anderen Benutzers ersetzen?';
                    UserSelectionOptionsLbl: Label 'Replace Current User,Select Different User',
                        Comment = 'de-DE=Aktuellen Benutzer ersetzen,Anderen Benutzer auswählen';
                begin
                    PersoDict := ImportUserPerso.RetrievePersoDict();

                    TempUserPersoVisualizer.SetPersoDict(PersoDict);
                    if Page.RunModal(Page::"PTE Extended User Perso Import", TempUserPersoVisualizer) <> Action::LookupOK then
                        exit;

                    case StrMenu(UserSelectionOptionsLbl, 0, UserSelectionLbl) of
                        1:
                            ImportUserPerso.ImportPersoDict(TempUserPersoVisualizer.GetPersoDict());
                        2:
                            if Page.RunModal(Page::"User Lookup", User) = Action::LookupOK then
                                ImportUserPerso.ImportPersoDict(User."User Security ID", TempUserPersoVisualizer.GetPersoDict());
                    end;
                end;
            }
            action(DownloadAll)
            {
                ApplicationArea = All;
                Caption = 'Download All',
                    Comment = 'de-DE=Alles herunterladen';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Downloads the user personalization settings for all users.',
                    Comment = 'de-DE=Lädt die Benutzereinstellungen für alle Benutzer herunter.';

                trigger OnAction()
                var
                    User: Record User;
                    ExportUserPerso: Codeunit "PTE Export User Perso";
                    UserIdList: List of [Guid];
                begin
                    User.SetLoadFields("User Security ID");
                    User.SetRange(State, User.State::Enabled);
                    if User.FindSet() then
                        repeat
                            UserIdList.Add(User."User Security ID");
                        until User.Next() = 0;
                    ExportUserPerso.Export(UserIdList);
                end;
            }
            action(DownloadSelection)
            {
                ApplicationArea = All;
                Caption = 'Download Selection',
                    Comment = 'de-DE=Auswahl herunterladen';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Downloads the user personalization settings for a selection of users.',
                    Comment = 'de-DE=Lädt die Benutzereinstellungen für eine Auswahl von Benutzern herunter.';

                trigger OnAction()
                var
                    User: Record User;
                    ExportUserPerso: Codeunit "PTE Export User Perso";
                    UserIdList: List of [Guid];
                begin
                    User.SetLoadFields("User Security ID");
                    User.SetRange(State, User.State::Enabled);
                    CurrPage.SetSelectionFilter(User);
                    if User.FindSet() then
                        repeat
                            UserIdList.Add(User."User Security ID");
                        until User.Next() = 0;
                    ExportUserPerso.Export(UserIdList);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenPersonalizedPages)
            {
                ApplicationArea = All;
                Caption = 'Open Personalized Pages',
                    Comment = 'de-DE=Personalisierte Seiten öffnen';
                Image = PostponedInteractions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Personalized Pages";
                ToolTip = 'Opens the page that shows all pages that can be personalized by the user.',
                    Comment = 'de-DE=Öffnet die Seite, die alle Seiten anzeigt, die vom Benutzer personalisiert wurden.';
            }
        }
    }

    var
        DownloadLbl: Label 'Download',
            Comment = 'de-DE=Herunterladen';
}
page 52551 "PTE Extended User Perso Import"
{
    ApplicationArea = All;
    Caption = 'Extended User Personalization Import',
        Comment = 'de-DE=Erweiterter Benutzerpersonalisierungs-Import';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "PTE User Perso Visualizer Temp";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Do Import"; Rec."Do Import")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to import the personalizations for this page.',
                        Comment = 'de-DE=Gibt an, ob die Personalisierungen für diese Seite importiert werden sollen.';
                }
                field("Page ID"; Rec."Page ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the page.',
                        Comment = 'de-DE=Gibt die ID der Seite an.';
                }
                field("Page Caption"; Rec."Page Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Caption of the page.',
                        Comment = 'de-DE=Gibt die Beschriftung der Seite an.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CheckAll)
            {
                ApplicationArea = All;
                Caption = 'Check All',
                    Comment = 'de-DE=Alle markieren';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Checks all pages for importing the personalizations.',
                    Comment = 'de-DE=Markiert alle Seiten für den Import der Personalisierungen.';

                trigger OnAction()
                begin
                    Rec.ModifyAll("Do Import", true);
                end;
            }
            action(CheckSelection)
            {
                ApplicationArea = All;
                Caption = 'Check Selection',
                    Comment = 'de-DE=Ausgewählte markieren';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Checks the selected pages for importing the personalizations.',
                    Comment = 'de-DE=Markiert die ausgewählten Seiten für den Import der Personalisierungen.';

                trigger OnAction()
                var
                    Position, View : Text;
                begin
                    Position := Rec.GetPosition();
                    View := Rec.GetView();
                    CurrPage.SetSelectionFilter(Rec);
                    Rec.ModifyAll("Do Import", true);
                    Rec.Reset();
                    if View <> '' then
                        Rec.SetView(View);
                    if Position <> '' then
                        Rec.SetPosition(Position);
                end;
            }
            action(UncheckAll)
            {
                ApplicationArea = All;
                Caption = 'Uncheck All',
                    Comment = 'de-DE=Alle Markierungen aufheben';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Unchecks all pages for importing the personalizations.',
                    Comment = 'de-DE=Hebt die Markierung aller Seiten für den Import der Personalisierungen auf.';

                trigger OnAction()
                begin
                    Rec.ModifyAll("Do Import", false);
                end;
            }
            action(UncheckSelection)
            {
                ApplicationArea = All;
                Caption = 'Uncheck Selection',
                    Comment = 'de-DE=Ausgewählte Markierungen aufheben';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Unchecks the selected pages for importing the personalizations.',
                    Comment = 'de-DE=Hebt die Markierung der ausgewählten Seiten für den Import der Personalisierungen auf.';

                trigger OnAction()
                var
                    Position, View : Text;
                begin
                    Position := Rec.GetPosition();
                    View := Rec.GetView();
                    CurrPage.SetSelectionFilter(Rec);
                    Rec.ModifyAll("Do Import", false);
                    Rec.Reset();
                    if View <> '' then
                        Rec.SetView(View);
                    if Position <> '' then
                        Rec.SetPosition(Position);
                end;
            }
        }
    }
}
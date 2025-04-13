{
  <summary>
  Die Unit ist für die GUI des Auswählens der Spieler da.
  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
}
unit fmSelectPlayers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.Buttons,

  uBase;

type
  /// <summary>
  /// die Bedingungen um ein Spiel starten zu können.
  /// </summary>
  TSelectCondition = (scIndividualNames, scEnoughPlayer);

  /// <summary>
  /// Menge von TSelectCondition.
  /// </summary>
  TSelectConditionSet = set of TSelectCondition;

const
  /// <summary>Menge aller Auswahlbedingungen.</summary>
  scALL = [scIndividualNames, scEnoughPlayer];

type
  /// <summary>
  /// Formular zur Auswahl der Spieler.
  /// </summary>
  TfmSelectPlayers = class(TForm)
    lbePlayer1: TLabeledEdit;
    lbePlayer2: TLabeledEdit;
    lbePlayer3: TLabeledEdit;
    lbePlayer4: TLabeledEdit;
    BitBtnOk: TBitBtn;
    BitBtnAbbrechen: TBitBtn;
    lbAccessConditions: TLabel;

    /// <summary>
    /// Ereignisbehandler, der aufgerufen wird, wenn sich der Text in einem der
    /// Spielernamen-Eingabefelder ändert.
    /// </summary>
    /// <param name="Sender">Das auslösende Objekt (eines der TLabeledEdit-Felder).</param>
    procedure lbePlayerChange(Sender: TObject);

    /// <summary>
    /// Ereignisbehandler, der beim Anzeigen des Formulars aufgerufen wird.
    /// </summary>
    /// <param name="Sender">Das auslösende Objekt.</param>
    procedure FormShow(Sender: TObject);
  private

    /// <summary>
    /// Prüft, ob alle eingegebenen Spielernamen eindeutig sind.
    /// </summary>
    /// <returns>True, wenn die Namen eindeutig sind, sonst False.</returns>
    function isIndividual: boolean;

    /// <summary>
    /// Ermittelt die aktuell erfüllten Auswahlbedingungen.
    /// </summary>
    /// <returns>Eine Menge, die die erfüllten Bedingungen enthält.</returns>
    function getSelectConditions: TSelectConditionSet;

    /// <summary>
    /// Aktualisiert das Formulars,Aktivierung des OK-Buttons und
    /// Anzeige von Meldungen.
    /// </summary>
    procedure refresh;
  public

    /// <summary>
    /// Gibt die Anzahl der aktiven Spieler zurück.
    /// </summary>
    /// <returns>Die Anzahl der aktiven Spieler.</returns>
    function getNumberOfActivePlayers: TActivePlayers;
    /// <summary>
    /// Gibt die Namen der aktiven Spieler zurück.
    /// </summary>
    /// <returns>Ein Array mit den Namen der aktiven Spieler.</returns>
    function getPlayerNames: TPlayerNames;
  end;

implementation

{$R *.dfm}

procedure TfmSelectPlayers.FormShow(Sender: TObject);
begin
  refresh;
end;

function TfmSelectPlayers.getNumberOfActivePlayers: TActivePlayers;
var
  lbeName: TLabeledEdit;
  id: TPlayerId;
  count: integer;
begin
  count := 0;
  for id := 0 to MAX_PLAYERS - 1 do
  begin
    lbeName := FindComponent('lbePlayer' + IntToStr(id + 1)) as TLabeledEdit;
    if lbeName.Text <> '' then
      inc(count);
  end;
  getNumberOfActivePlayers := count;
end;

function TfmSelectPlayers.getPlayerNames: TPlayerNames;
var
  playerNames: TPlayerNames;
  lbeName: TLabeledEdit;
  id: TPlayerId;
  count: integer;
begin
  count := 0;
  for id := 0 to MAX_PLAYERS - 1 do
  begin
    lbeName := FindComponent('lbePlayer' + IntToStr(id + 1)) as TLabeledEdit;
    if lbeName.Text <> '' then
    begin
      playerNames[count] := lbeName.Text;
      inc(count);
    end;

  end;
  getPlayerNames := playerNames;
end;

function TfmSelectPlayers.getSelectConditions: TSelectConditionSet;
var
  successConditions: TSelectConditionSet;
begin
  successConditions := [];
  if isIndividual then
    Include(successConditions, scIndividualNames);

  if getNumberOfActivePlayers >= MIN_PLAYERS then
    Include(successConditions, scEnoughPlayer);

  getSelectConditions := successConditions;
end;

function TfmSelectPlayers.isIndividual: boolean;
var
  playerNames: TPlayerNames;
  numOfPlyers: TActivePlayers;
begin
  isIndividual := true;
  playerNames := getPlayerNames;
  numOfPlyers := getNumberOfActivePlayers;
  if numOfPlyers >= MIN_PLAYERS then
  begin
    for var id := 0 to numOfPlyers - 2 do
      for var innerId := id + 1 to numOfPlyers - 1 do
        if playerNames[id] = playerNames[innerId] then
          isIndividual := false;
  end;
end;

procedure TfmSelectPlayers.lbePlayerChange(Sender: TObject);
begin
  refresh;
end;

procedure TfmSelectPlayers.refresh;
var
  conditionSet: TSelectConditionSet;
begin
  conditionSet := getSelectConditions;

  if not(scIndividualNames in conditionSet) then
    lbAccessConditions.Caption := 'Spieler sind nicht individuel';

  if not(scEnoughPlayer in conditionSet) then
    lbAccessConditions.Caption := 'nicht genug Spieler';

  if conditionSet = scALL then
  begin
    lbAccessConditions.font.Color := clGreen;
    lbAccessConditions.Caption := 'alles startbereit';
    BitBtnOk.Enabled := true;
  end
  else
  begin
    BitBtnOk.Enabled := false;
    lbAccessConditions.font.Color := clRed;
  end;
end;

end.

{
  <summary>
  Ist die Unit für die game GUI.
  Hier wird das Spiel dargestellt und dem Benutzer
  die Möglichkeit gegeben Aktionen auszuführen.
  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
  <version>1.0</version>
  <remarks></remarks>
}
unit fmGame;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  types,

  uBase,
  uInGame,
  fmGame.utils,
  uLogging,
  fmCheatThrow,
  fmSelectPlayers, Vcl.ExtDlgs,
  Vcl.Buttons, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage;

const
  /// <summary>
  /// Verzögert die nächste Spielzug (in Millisekunden).
  /// </summary>
  DELAY_NEXT_MOVE_INTERVAL = 2000;

type
  /// <summary>
  /// TfrmGame stellt das Hauptformular des Spiels dar und verwaltet die Benutzeroberfläche.
  /// </summary>
  TfrmGame = class(TForm)
    pnlCards: TPanel;
    pnlFreeCubes: TPanel;
    pnlSavedCubes: TPanel;
    lblCubeTable: TLabel;
    lblSavedCubeArea: TLabel;
    igGcAnimals: TImage;
    igGcDiamond: TImage;
    igGcGoldCoin: TImage;
    igGcGuardian: TImage;
    igGcPirate: TImage;
    igGcTreasureIsland: TImage;
    igGcSkull1: TImage;
    igGcPirateship2: TImage;
    igGcPirateship3: TImage;
    igGcPirateship4: TImage;
    igGcSkull2: TImage;
    btnWerten: TButton;
    btnThrow: TButton;
    pnlPlayers: TPanel;
    pnlPlayerNames: TPanel;
    lbPlayer0Name: TLabel;
    lbPlayer1Name: TLabel;
    lbPlayer2Name: TLabel;
    lbPlayer3Name: TLabel;
    pnlPlayerScores: TPanel;
    lbPlayer0Score: TLabel;
    lbPlayer1Score: TLabel;
    lbPlayer2Score: TLabel;
    lbPlayer3Score: TLabel;
    igCube0: TImage;
    igCube1: TImage;
    igCube2: TImage;
    igCube3: TImage;
    igCube4: TImage;
    igCube5: TImage;
    igCube6: TImage;
    igCube7: TImage;
    pnlSides: TPanel;
    igDiamond: TImage;
    igGoldCoin: TImage;
    igMonkey: TImage;
    igParrot: TImage;
    igSaber: TImage;
    igSkull: TImage;
    igBackSkull: TImage;
    igBackSaber: TImage;
    btnLoadGame: TButton;
    dlgOpenPkFile: TOpenDialog;
    btnSaveGame: TButton;
    dlgSavePkFile: TSaveDialog;
    mmoLog: TMemo;
    lblCurrentCard: TLabel;
    pnlCardInfo: TPanel;
    igGcBack: TImage;
    Memo1: TMemo;
    lbCardinfo: TLabel;
    tmGameCardInfo: TTimer;
    Panel1: TPanel;
    igDiamondGray: TImage;
    igGoldCoinGray: TImage;
    igMonkeyGray: TImage;
    igParrotGray: TImage;
    igSaberGray: TImage;
    igSkullRed: TImage;
    btnShowLog: TButton;
    tmDelayNextMove: TTimer;
    igWinPlade: TImage;
    igWinPladeNine: TImage;
    btbtnEndGame: TBitBtn;
    pnlStartScreen: TPanel;
    igStartScreen: TImage;
    btnGoToStartScreen: TButton;
    Label1: TLabel;
    btnStart: TButton;

    /// <summary>
    /// Ereignisbehandlung beim Erstellen des Formulars.
    /// Initialisiert die Würfelbilder, Seitenbilder und erstellt die InGame-Instanz.
    /// Setzt die ClientWidth und startet das Warten auf ein Spiel.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure FormCreate(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung für den Klick auf den Wertungs-Button.
    /// Signalisiert das Ende eines Zuges durch die Aktion gaEndMove.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure btnWertenClick(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung für den Klick auf den Würfelwurf-Button.
    /// Führt die Aktion gaThrow aus.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure btnThrowClick(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung für den Klick auf den Start-Button.
    /// Startet das Spiel durch Ausführen der Aktion gaStartGame.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure btnStartClick(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung für den Klick auf den Laden-Button.
    /// Lädt einen Spielstand durch Ausführen der Aktion gaLoadGame.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure btnLoadGameClick(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung für den Klick auf den Speichern-Button.
    /// Speichert den aktuellen Spielstand durch Ausführen der Aktion gaSaveGame.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure btnSaveGameClick(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung beim Schließen des Formulars.
    /// Legt fest, ob das Formular geschlossen werden kann, basierend darauf, ob ein Spiel läuft.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    /// <param name="CanClose">Flag, das angibt, ob das Formular geschlossen werden kann.</param>
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);

    /// <summary>
    /// Ereignisbehandlung beim Drücken der Maustaste auf einem Würfelbild.
    /// Führt abhängig von der Maustaste und den möglichen Aktionen die entsprechende Aktion aus.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    /// <param name="Button">Die gedrückte Maustaste.</param>
    /// <param name="Shift">Die gedrückten Shift-Zustände.</param>
    /// <param name="X">Die X-Koordinate der Maus.</param>
    /// <param name="Y">Die Y-Koordinate der Maus.</param>
    procedure igCubeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    /// <summary>
    /// Ereignisbehandlung bei Mausbewegung über einem Würfelbild.
    /// Ändert den Cursor basierend auf den möglichen Aktionen für den Würfel.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    /// <param name="Shift">Die gedrückten Shift-Zustände.</param>
    /// <param name="X">Die X-Koordinate der Maus.</param>
    /// <param name="Y">Die Y-Koordinate der Maus.</param>
    procedure igCubeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

    /// <summary>
    /// Ereignisbehandlung beim Betreten einer Spielkarte.
    /// Aktiviert den Timer zur Anzeige von Karteninformationen, wenn keine gespeicherten Würfel vorhanden sind.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure gameCardMouseEnter(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung beim Verlassen des Kartenhintergrunds.
    /// Blendet das Panel für Karteninformationen aus.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure cardBackroundMouseLeave(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung des Timers zur Anzeige von Karteninformationen.
    /// Wechselt die Sichtbarkeit des Karteninformationspanels und aktualisiert den angezeigten Text.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure tmGameCardInfoTimer(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung beim Verlassen einer Spielkarte.
    /// Deaktiviert den Timer zur Anzeige von Karteninformationen.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure gameCardMouseLeave(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung für den Klick auf den Log-Button.
    /// Schaltet die Loganzeige ein oder aus.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure btnShowLogClick(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung des Timers zur Verzögerung der nächsten Spielzugs.
    /// Führt die nächste Spielaktion aus, basierend auf dem aktuellen Spielstatus und den möglichen Aktionen.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure tmDelayNextMoveTimer(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung beim Drücken einer Taste.
    /// Schaltet den Cheat-Modus um, wenn Alt+C gedrückt wird.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    /// <param name="Key">Der gedrückte Tastencode.</param>
    /// <param name="Shift">Die gedrückten Shift-Zustände.</param>
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

    /// <summary>
    /// Ereignisbehandlung beim Zerstören des Formulars.
    /// Gibt die InGame-Instanz frei.
    /// </summary>
    /// <param name="Sender">Der Sender des Ereignisses.</param>
    procedure FormDestroy(Sender: TObject);

    /// <summary>
    /// Ereignisbehandlung für den Klick auf den Button zum Wechseln zum Startbildschirm.
    /// Setzt das Spiel in den Wartezustand.
    /// </summary>

    procedure btnGoToStartScreenClick(Sender: TObject);

  strict private
    /// <summary>
    /// Referenz auf die InGame-Logik.
    /// </summary>
    ingame: TInGame;

    /// <summary>
    /// Array der Bilder der Würfel.
    /// </summary>
    cubeImages: array [TCubeId] of TImage;

    /// <summary>
    /// Array der Rotationswinkel der Würfel.
    /// </summary>
    cubeRotationAngles: array [TCubeId] of Integer;

    /// <summary>
    /// Arrays der normalen und der Totenkopf-Insel-Seitenbilder.
    /// </summary>
    normalSideImages, skullIslandSideImages: array [TCubeSide] of TImage;

    /// <summary>
    /// Array der Bilder der Spielkarten.
    /// </summary>
    cardImages: array [TGameCard] of TImage;

    /// <summary>
    /// Gibt die ID des Würfels anhand des übergebenen Bildes zurück.
    /// </summary>
    /// <param name="cubeImage">Das Würfelbild.</param>
    /// <returns>Die Würfel-ID.</returns>
    function getCubeId(cubeImage: TImage): TCubeId;

    /// <summary>
    /// Liefert das Bild der Würfelseite für den angegebenen Würfel, abhängig vom aktuellen Spielmodus.
    /// </summary>
    /// <param name="id">Die ID des Würfels.</param>
    /// <returns>Das Bild der entsprechenden Würfelseite.</returns>
    function getSideImage(id: TCubeId): TImage;

    /// <summary>
    /// Überprüft, ob aktuell ein Spiel läuft.
    /// </summary>
    /// <returns>True, wenn ein Spiel läuft, sonst False.</returns>
    function queryRunningGame: boolean;

    /// <summary>
    /// Aktualisiert die Benutzeroberfläche basierend auf der aktuellen Spielsituation und der ausgeführten Aktion.
    /// Aktualisiert Spielerinformationen, Kartenanzeige, Würfelanzeige und Schaltflächen.
    /// </summary>
    /// <param name="action">Die zuletzt ausgeführte Aktion.</param>
    /// <param name="ids">Die betroffenen Würfel-IDs.</param>
    procedure refresh(action: TAction; ids: TCubeIds);

    /// <summary>
    /// Führt eine Aktion auf einem bestimmten Würfel aus.
    /// </summary>
    /// <param name="action">Die auszuführende Aktion.</param>
    /// <param name="id">Die ID des betroffenen Würfels.</param>
    procedure doAction(action: TAction; id: TCubeId = 0);
  public

  end;

var
  /// <summary>
  /// Globale Instanz des TfrmGame Formulars.
  /// </summary>
  frmGame: TfrmGame;

implementation

uses
  uMemCounter,uAction, uImageUtils, StrUtils;
{$R *.dfm}

procedure TfrmGame.btnThrowClick(Sender: TObject);
begin
  doAction(gaThrow);
end;

procedure TfrmGame.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := queryRunningGame;
end;

procedure TfrmGame.FormCreate(Sender: TObject);
begin

  cubeImages[0] := igCube0;
  cubeImages[1] := igCube1;
  cubeImages[2] := igCube2;
  cubeImages[3] := igCube3;
  cubeImages[4] := igCube4;
  cubeImages[5] := igCube5;
  cubeImages[6] := igCube6;
  cubeImages[7] := igCube7;

  for var id := Low(TCubeId) to High(TCubeId) do
    cubeRotationAngles[id] := 0;

  normalSideImages[csDiamond] := igDiamond;
  normalSideImages[csGoldCoin] := igGoldCoin;
  normalSideImages[csMonkey] := igMonkey;
  normalSideImages[csParrot] := igParrot;
  normalSideImages[csSaber] := igSaber;
  normalSideImages[csSkull] := igSkull;

  skullIslandSideImages[csDiamond] := igDiamondGray;
  skullIslandSideImages[csGoldCoin] := igGoldCoinGray;
  skullIslandSideImages[csMonkey] := igMonkeyGray;
  skullIslandSideImages[csParrot] := igParrotGray;
  skullIslandSideImages[csSaber] := igSaberGray;
  skullIslandSideImages[csSkull] := igSkullRed;

  cardImages[gcAnimals] := igGcAnimals;
  cardImages[gcGuardian] := igGcGuardian;
  cardImages[gcDiamond] := igGcDiamond;
  cardImages[gcGoldCoin] := igGcGoldCoin;
  cardImages[gcSkull1] := igGcSkull1;
  cardImages[gcSkull2] := igGcSkull2;
  cardImages[gcPirate] := igGcPirate;
  cardImages[gcPirateShip2] := igGcPirateship2;
  cardImages[gcPirateShip3] := igGcPirateship3;
  cardImages[gcPirateShip4] := igGcPirateship4;
  cardImages[gcTreasureIsland] := igGcTreasureIsland;

  ingame := createObject(TInGame) as TInGame;

  ClientWidth := mmoLog.left;

  doAction(gaWaitForGame);
end;

procedure TfrmGame.FormDestroy(Sender: TObject);
begin
  releaseInstance(ingame);
end;

procedure TfrmGame.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift * [ssAlt] = [ssAlt]) and (Key = Ord('C')) then
    ingame.setCheatMode(not ingame.getCheatMode);
end;

procedure TfrmGame.igCubeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  actions: TActions;
  image: TImage;
  id: TCubeId;
begin

  image := Sender as TImage;
  id := getCubeId(image);

  actions := ingame.getPossibleCubeActions(id);
  if gaFreeCube in actions then
    cubeImages[id].Cursor := crHandPoint
  else if gaSaveSavedCube in actions then
    cubeImages[id].Cursor := crHandPoint
  else if gaSaveCube in actions then
    cubeImages[id].Cursor := crHandPoint
  else if gaFreeSkull in actions then
    cubeImages[id].Cursor := crHandPoint
  else
    cubeImages[id].Cursor := crNo;
end;

procedure TfrmGame.cardBackroundMouseLeave(Sender: TObject);
begin
  pnlCardInfo.Visible := false;
end;

procedure TfrmGame.doAction(action: TAction; id: TCubeId);
var
  ids: TCubeIds;
begin
  ids := [id];
  uAction.doAction(ingame, mmoLog, action, ids);
  refresh(action, ids);
end;

procedure TfrmGame.gameCardMouseEnter(Sender: TObject);
begin
  if [] = ingame.getCubeIds([ctSaveSaved]) then
    tmGameCardInfo.Enabled := true;
end;

procedure TfrmGame.gameCardMouseLeave(Sender: TObject);
begin
  tmGameCardInfo.Enabled := false;
end;

procedure TfrmGame.igCubeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  actions: TActions;
  image: TImage;
  id: TCubeId;
begin

  image := Sender as TImage;
  id := getCubeId(image);

  actions := ingame.getPossibleCubeActions(id);
  if gaFreeCube in actions then
    doAction(gaFreeCube, id)
  else if (gaSaveSavedCube in actions) and (Button = mbRight) then
    doAction(gaSaveSavedCube, id)
  else if (gaSaveCube in actions) and (Button = mbLeft) then
    doAction(gaSaveCube, id)
  else if gaFreeSkull in actions then
    doAction(gaFreeSkull, id);
end;

procedure TfrmGame.btnWertenClick(Sender: TObject);
begin
  doAction(gaEndMove);
end;

procedure TfrmGame.btnGoToStartScreenClick(Sender: TObject);
begin
  doAction(gaWaitForGame);
end;

procedure TfrmGame.btnLoadGameClick(Sender: TObject);
begin
  doAction(gaLoadGame);
end;

procedure TfrmGame.btnSaveGameClick(Sender: TObject);
begin
  doAction(gaSaveGame);
end;

procedure TfrmGame.btnShowLogClick(Sender: TObject);
var
  extended: Integer;
begin
  extended := mmoLog.left + mmoLog.Width + 20;
  if ClientWidth = extended then
  begin
    ClientWidth := mmoLog.left;
    btnShowLog.Caption := 'Log einblenden';
  end
  else
  begin
    ClientWidth := extended;
    btnShowLog.Caption := 'Log ausblenden'
  end;

end;

procedure TfrmGame.btnStartClick(Sender: TObject);
begin
  doAction(gaStartGame);
end;

function TfrmGame.queryRunningGame: boolean;
begin
  queryRunningGame := uAction.queryRunningGame(ingame);

end;

procedure TfrmGame.refresh(action: TAction; ids: TCubeIds);
/// <summary>
/// Aktualisiert die Spieleranzeige.
/// </summary>
  procedure refreshPlayers;
  var
    id: TPlayerId;
    lbName, lbScore: TLabel;
    color: TColor;
    winImage: TImage;
  begin
    for id := 0 to MAX_PLAYERS - 1 do
    begin
      lbName := FindComponent('lbPlayer' + IntToStr(id) + 'Name') as TLabel;
      lbScore := FindComponent('lbPlayer' + IntToStr(id) + 'Score') as TLabel;

      lbName.Visible := false;
      lbScore.Visible := false;

      if ingame.getGameStatus <> gsWaiting then
        if id < ingame.getActivePlayers then
          with ingame.getPlayerStats(id) do
          begin
            lbName.Caption := Name;
            lbScore.Caption := IntToStr(Points);
            lbName.Visible := true;
            lbScore.Visible := true;

            if id = ingame.getCurrentPlayerId then
              color := clRed
            else
              color := clwindowText;

            lbName.Font.color := color;
            lbScore.Font.color := color;
          end;
    end;

    igWinPlade.Visible := false;
    igWinPladeNine.Visible := false;
    if gsFinished = ingame.getGameStatus then
    begin
      case ingame.getGameWinKind of
        gwNormal:
          winImage := igWinPlade;
        gwNine:
          winImage := igWinPladeNine;
      end;

      lbName := FindComponent('lbPlayer' + IntToStr(ingame.getCurrentPlayerId) + 'Name') as TLabel;
      winImage.Parent := pnlPlayerNames;
      winImage.Top := lbName.Top;
      winImage.left := lbName.left - winImage.Width; // + lbName.Width + 15;
      winImage.Visible := true;
    end;
  end;

/// <summary>
/// Aktualisiert die Anzeige der aktuellen Spielkarte.
/// </summary>
  procedure refreshCard;
  var
    card: TGameCard;
  begin
    for card := Low(TGameCard) to High(TGameCard) do
      cardImages[card].Visible := (gsWaiting <> ingame.getGameStatus) and (card = ingame.getCurrentCard);
  end;

/// <summary>
/// Aktualisiert den Status der Aktions-Buttons.
/// </summary>
  procedure refreshButtons;
  var
    actions: TActions;
  begin
    actions := ingame.getPossibleActions;

    btnStart.Enabled := (gaStartGame in actions);
    btnLoadGame.Enabled := gaLoadGame in actions;
    btnSaveGame.Enabled := gaSaveGame in actions;
    btnWerten.Enabled := (gaEndMove in actions) and (msInMove = ingame.getMoveStatus);
    btnThrow.Enabled := gaThrow in actions;
    btnGoToStartScreen.Enabled := gsWaiting <> ingame.getGameStatus;
    btbtnEndGame.Enabled := true;

    btnShowLog.Enabled := gsWaiting <> ingame.getGameStatus;
  end;

/// <summary>
/// Aktualisiert die Sichtbarkeit der Würfelbilder.
/// </summary>
  procedure refreshCubes;
  var
    cubeId: TCubeId;
    Visible: boolean;
  begin
    Visible := ((gsRunning = ingame.getGameStatus) and (ingame.getNumberOfThrows > 0) or (gsFinished = ingame.getGameStatus));
    for cubeId := 0 to NUMBER_OF_CUBES - 1 do
      cubeImages[cubeId].Visible := Visible;
  end;

/// <summary>
/// Aktualisiert die Position und Darstellung der Würfel in der freien Spieltabelle.
/// Rotiert die Würfel zufällig und ordnet sie neu an.
/// </summary>
/// <param name="newCubes">Die Menge der neu hinzukommenden Würfel.</param>
  procedure refreshTable(newCubes: TCubeIds);
  var
    id: TCubeId;
    placements: TPlacements;
    placedCubes: TCubeIds;
  begin
    placedCubes := ingame.getCubeIds([ctKilled, ctFree]);
    for id in newCubes do
    begin
      cubeImages[id].Parent := pnlFreeCubes;
      cubeRotationAngles[id] := random(360);
      RotateBitmapInPlace(cubeImages[id], getSideImage(id), cubeRotationAngles[id]);
    end;

    placements.cubeIds := placedCubes + newCubes;
    for id in placements.cubeIds do
      placements.rects[id] := cubeImages[id].BoundsRect;

    newRandomPlacements(newCubes, placements, pnlFreeCubes.clientRect.BottomRight);

    for id in newCubes do
    begin
      cubeImages[id].BoundsRect := placements.rects[id];
    end;

    if msEndMoveRequired = ingame.getMoveStatus then
    begin
      for id := Low(TCubeId) to High(TCubeId) do
        if ingame.getCubeSide(id) = csSkull then
        begin
          case ingame.getMoveMode of
            mmNormal, mmPirateShip:
              RotateBitmapInPlace(cubeImages[id], igSkullRed, cubeRotationAngles[id]);
            mmSkullIsland:
              RotateBitmapInPlace(cubeImages[id], igSkull, cubeRotationAngles[id]);
          end;
        end;
    end;
  end;

/// <summary>
/// Aktualisiert die Anzeige der gespeicherten Würfel in den entsprechenden Panels.
/// Ordnet die Würfel basierend auf ihrem Zustand (ctSaved oder ctSaveSaved) in einem Raster an.
/// </summary>
/// <param name="state">Der Zustand der anzuzeigenden Würfel.</param>
  procedure refreshSavedCubes(state: TCubeState);
  var
    panel: TPanel;
    point: TPoint;
    index: Integer;
    side: TCubeSide;
    id: TCubeId;
    ids: TCubeIds;
    rect: tRect;
  begin
    assert(state in [ctSaved, ctSaveSaved], 'internal error in refreshSavedCubes');
    index := 0;
    if state = ctSaved then
      panel := pnlSavedCubes
    else if state = ctSaveSaved then
      panel := pnlCards;

    rect := panel.clientRect;
    ids := ingame.getCubeIds([state]);
    for side in csALL do
    begin
      for id in ids do
      begin
        if side = ingame.getCubeSide(id) then
        begin
          point := getCubeGridPos(index, COLUMS, rect);

          cubeImages[id].Parent := panel;

          cubeImages[id].left := point.X;
          cubeImages[id].Top := point.Y;

          cubeImages[id].Picture := getSideImage(id).Picture;
          cubeImages[id].Width := CUBE_SIZE;
          cubeImages[id].Height := CUBE_SIZE;
          inc(index);
        end;
      end;
    end;

  end;

// main function
var
  gameStatus: TGameStatus;
begin
  gameStatus := ingame.getGameStatus;

  pnlCardInfo.Visible := false;

  refreshPlayers;
  refreshCard;
  refreshCubes; // (action)
  refreshButtons;

  case gameStatus of
    gsWaiting:
      begin
        pnlStartScreen.Visible := true;
        pnlStartScreen.BringToFront;

        igBackSaber.Visible := false;
        igBackSkull.Visible := false;

        ClientWidth := mmoLog.left;
        btnShowLog.Caption := 'Log einblenden';
      end;
    gsRunning:
      begin
        pnlStartScreen.Visible := false;

        igBackSaber.Visible := ingame.getMoveMode = mmPirateShip;
        igBackSkull.Visible := ingame.getMoveMode = mmSkullIsland;

        case action of
          gaSaveCube:
            refreshSavedCubes(ctSaved);
          gaSaveSavedCube:
            refreshSavedCubes(ctSaveSaved);
          gaFreeCube:
            begin
              refreshTable(ids);
              refreshSavedCubes(ctSaved);
              refreshSavedCubes(ctSaveSaved);
            end;
          gaFreeSkull, gaThrow:
            begin
              refreshTable(ids);
              if msEndMoveRequired = ingame.getMoveStatus then
              begin
                tmDelayNextMove.Interval := DELAY_NEXT_MOVE_INTERVAL div 2;
                tmDelayNextMove.Enabled := true;
              end;
            end;
          gaEndMove:
            begin
              if msEndMoveRequired = ingame.getMoveStatus then
                tmDelayNextMove.Interval := DELAY_NEXT_MOVE_INTERVAL div 2
              else
                tmDelayNextMove.Interval := DELAY_NEXT_MOVE_INTERVAL;
              tmDelayNextMove.Enabled := true;
            end;
        end;
      end;
    gsFinished:
      begin
        if ingame.getGameWinKind = gwNine then
          refreshTable(ids);
      end;
  end;
end;

function TfrmGame.getCubeId(cubeImage: TImage): TCubeId;
var
  id: TCubeId;
begin
  id := 0;
  while cubeImage <> cubeImages[id] do
  begin
    assert(id < High(TCubeId), 'internal error: TfrmGame.getCubeId');
    inc(id);
  end;
  getCubeId := id;
end;

function TfrmGame.getSideImage(id: TCubeId): TImage;
begin
  case ingame.getMoveMode of
    mmNormal, mmPirateShip:
      getSideImage := normalSideImages[ingame.getCubeSide(id)];
    mmSkullIsland:
      getSideImage := skullIslandSideImages[ingame.getCubeSide(id)];
  end;
end;

procedure TfrmGame.tmGameCardInfoTimer(Sender: TObject);
begin
  if pnlCardInfo.Visible then
    pnlCardInfo.Visible := false
  else
  begin
    pnlCardInfo.Visible := true;
    lbCardinfo.Caption := CARD_INFO_TEXTS[ingame.getCurrentCard];
  end;
  tmGameCardInfo.Enabled := false;
end;

procedure TfrmGame.tmDelayNextMoveTimer(Sender: TObject);
begin
  tmDelayNextMove.Enabled := false;
  if msEndMoveRequired = ingame.getMoveStatus then
    doAction(gaEndMove)
  else if gaNextMove in ingame.getPossibleActions then
    doAction(gaNextMove);
end;

end.

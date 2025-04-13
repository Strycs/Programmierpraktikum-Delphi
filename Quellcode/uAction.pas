{
  <summary>
  Diese Unit hat als einzige Aufgabe die Aktionen die die game UI d.h. frmGame ausführt,
  auszulagern und zu verarbeiten und relevante Details zu implementieren.
  Sie kümmert sich auch um das Logging.
  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
  <version>1.0</version>
  <remarks></remarks>
}
unit uAction;

interface

uses
  uInGame, uBase, SysUtils, vcl.stdCtrls;

/// <summary>
/// Führt die angegebene Aktion im Spiel aus, indem interne Abläufe wie Spielstart, Laden, Speichern,
/// Würfelaktionen und Zugwechsel verwaltet werden.
/// </summary>
/// <param name="ingame">Die InGame-Instanz, die den aktuellen Spielzustand verwaltet.</param>
/// <param name="mmoLog">Das Memo zur Protokollierung von Spielereignissen.</param>
/// <param name="action">Die auszuführende Aktion.</param>
/// <param name="ids">Die betroffenen Würfel-IDs, ggf. als Eingabe oder Ausgabeparameter.</param>
procedure doAction(ingame: TIngame; mmoLog: TMemo; action: TAction; var ids: TCubeIds);

/// <summary>
/// Überprüft, ob ein laufendes Spiel beendet werden kann, indem entweder kein Spiel läuft oder
/// der Benutzer das Beenden des laufenden Spiels bestätigt.
/// </summary>
/// <param name="ingame">Die InGame-Instanz, die den aktuellen Spielzustand verwaltet.</param>
/// <returns>True, wenn das Spiel beendet werden kann, sonst False.</returns>
function queryRunningGame(ingame: TIngame): boolean;

implementation

uses
  system.classes, vcl.Dialogs, vcl.Controls, fmSelectPlayers, fmCheatThrow, uLogging, uMemCounter;

function queryRunningGame(ingame: TIngame): boolean;
var
  rslt: boolean;
begin
  rslt := false;
  if ingame.getGameStatus <> gsRunning then
    rslt := true
  else
    rslt := MessageDlg('Möchten Sie das laufende Spiel beenden?', mtWarning, [mbOK, mbCancel], 0) <> mrCancel;

  queryRunningGame := rslt;
end;

function cheatThrow(ingame: TIngame; throwables: TCubeIds): boolean;
var
  cheatCubes: TCubeIdSides;
  frmCheatThrow: TfrmCheatThrow;
begin
  cheatThrow := false;

  for var id := Low(TCubeId) to High(TCubeId) do
    cheatCubes.sides[id] := ingame.getCubeSide(id);
  cheatCubes.ids := throwables;

  frmCheatThrow := createComponent(TfrmCheatThrow) as TfrmCheatThrow;
  try
    frmCheatThrow.setThrowables(cheatCubes);
    if frmCheatThrow.ShowModal = mrOk then
    begin
      cheatCubes := frmCheatThrow.getCubeIdSides;
      ingame.throwCubes(@cheatCubes);
      cheatThrow := true;
    end;
  finally
    releaseInstance(frmCheatThrow);
  end;
end;

procedure doAction(ingame: TIngame; mmoLog: TMemo; action: TAction; var ids: TCubeIds);
/// <summary>
/// Startet ein neues Spiel, sofern ein es erlaubt ist.
/// </summary>
  procedure startGame;
  var
    fmSelectPlayers: TfmSelectPlayers;
  begin
    if queryRunningGame(ingame) then
    begin
      fmSelectPlayers := TfmSelectPlayers(createComponent(TfmSelectPlayers));
      try
        if fmSelectPlayers.ShowModal = mrOk then
        begin
          ingame.start(fmSelectPlayers.getPlayerNames, fmSelectPlayers.getNumberOfActivePlayers);
          logStartGame(mmoLog, ingame);
        end;
      finally
        releaseInstance(fmSelectPlayers);
      end;
    end;
  end;

/// <summary>
/// Lädt ein Spiel aus einer Datei, sofern es erlabt ist.
/// </summary>
  procedure loadGame;
  var
    dlg: TOpenDialog;
  begin
    if queryRunningGame(ingame) then
      dlg := createComponent(TOpenDialog) as TOpenDialog;
    with dlg do
      try
        DefaultExt := 'pk';
        Filter := 'pirateFiles|*.PK';
        FileName := ingame.getLastFileName;
        if Execute then
        begin
          try
            ingame.loadGame(FileName);
            logLoadGame(mmoLog, ingame, ingame.getLastFileName);
          except
            on E: Exception do
            begin
              logException(mmoLog, E);
              raise Exception.Create('Laden der Datei fehlgeschlagen:'#13#10#13#10 + E.Message);
            end;
          end;
        end;
      finally
        releaseInstance(dlg);
      end;
  end;

/// <summary>
/// Speichert das aktuelle Spiel in eine Datei.
/// </summary>
  procedure saveGame;
  var
    dlg: TSaveDialog;
  begin
    dlg := createComponent(TSaveDialog) as TSaveDialog;
    with dlg do
      try
        DefaultExt := 'pk';
        Filter := 'Pirate Files|*.PK';
        FileName := ingame.getLastFileName;
        Options := [ofHideReadOnly, ofExtensionDifferent, ofEnableSizing];
        if Execute then
        begin
          try
            if not FileExists(FileName) or (MessageDlg('Möchten Sie die existierende Datei überschreiben?', mtWarning,
              [mbOK, mbCancel], 0) <> mrCancel) then
            begin
              ingame.saveGame(FileName);
              logSaveGame(mmoLog, ingame, ingame.getLastFileName);
            end;
          except
            on E: Exception do
            begin
              logException(mmoLog, E);
              raise Exception.Create('Speichern fehlgeschlagen:'#13#10#13#10 + E.Message);
            end;
          end;
        end;
      finally
        releaseInstance(dlg);
      end;
  end;

/// <summary>
/// Wirft die Würfel. Wendet den Cheat-Modus an, falls dieser aktiviert ist.
/// </summary>
  function throwCubes: TCubeIds;
  var
    throwables: TCubeIds;
  begin
    throwables := ingame.getCubeIds([ctFree]);
    if not ingame.getCheatMode or not cheatThrow(ingame, throwables) then
      ingame.throwCubes;
    throwCubes := throwables;
  end;

  function first(const ids: TCubeIds): TCubeId;
    function isOnlyOneInSet(const ids: TCubeIds): boolean;
    var
      count: Integer;
    begin
      count := 0;
      isOnlyOneInSet := false;

      for var id := Low(TCubeId) to High(TCubeId) do
        if id in ids then
          inc(count);

      isOnlyOneInSet := count = 1;
    end;

  begin
    Assert(isOnlyOneInSet(ids), 'Error more then one id in Set');
    first := 0;
    for var id := Low(TCubeId) to High(TCubeId) do
      if id in ids then
        first := id;
  end;

begin
  Assert(action in ingame.getPossibleActions, 'internal ERROR: doAction');

  case action of

    gaWaitForGame:
      if queryRunningGame(ingame) then
        ingame.waitForGame;

    gaStartGame:
      startGame;
    gaSaveGame:
      saveGame;
    gaLoadGame:
      loadGame;

    gaSaveCube:
      begin

        ingame.saveCube(first(ids));
        logSaveCube(mmoLog, ingame, first(ids));
      end;

    gaSaveSavedCube:
      begin
        ingame.saveSavedCube(first(ids));
        logSaveSavedCube(mmoLog, ingame, first(ids));
      end;
    gaFreeCube:
      begin
        ingame.FreeCube(first(ids));
        logFreeCube(mmoLog, ingame, first(ids));
      end;
    gaFreeSkull:
      begin
        if not ingame.getCheatMode or not cheatThrow(ingame, ids) then
          ingame.throwSkull(first(ids));
        logFreeSkull(mmoLog, ingame, first(ids))
      end;

    gaThrow:
      begin
        ids := throwCubes;
        logThrow(mmoLog, ingame, ids);
      end;

    gaEndMove:
      begin
        ingame.endMove;
        logEndMove(mmoLog, ingame);
      end;
    gaNextMove:
      begin
        ingame.nextMove;
        logStartMove(mmoLog, ingame);
      end;
  end;
end;

end.

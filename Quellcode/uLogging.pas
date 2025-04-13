{
  <summary>

  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
  <version>1.0</version>
  <remarks></remarks>
}
{------------------------------------------------------------------------------
Dieses Modul bildet das zentrale Protokollierungssystem des Spiels ab. Es zeichnet alle
wesentlichen Spielereignisse sowie relevante Fehlermeldungen auf, um den Spielablauf und
eventuelle Probleme transparent zu dokumentieren.

Autoren: Morten Schobert, 12.03.2025
------------------------------------------------------------------------------}
unit uLogging;

interface

uses
  uBase,
  uInGame,
  Vcl.StdCtrls,
  SysUtils;

/// <summary>
/// Protokolliert den Start eines neuen Spiels.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt, in das protokolliert wird.</param>
/// <param name="ingame">Das TInGame-Objekt, das den Spielzustand enthält.</param>
procedure logStartGame(mmoLog: TMemo; ingame: TInGame);

/// <summary>
/// Protokolliert das Laden eines Spielstands.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt, in das protokolliert wird.</param>
/// <param name="ingame">Das TInGame-Objekt, das den Spielzustand enthält.</param>
/// <param name="fName">Der Dateiname des geladenen Spielstands.</param>
procedure logLoadGame(mmoLog: TMemo; ingame: TInGame; fName: string);

/// <summary>
/// Protokolliert das Speichern eines Spielstands.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt, in das protokolliert wird.</param>
/// <param name="ingame">Das TInGame-Objekt, das den Spielzustand enthält.</param>
/// <param name="fName">Der Dateiname, in den gespeichert wird.</param>
procedure logSaveGame(mmoLog: TMemo; ingame: TInGame; fName: string);

/// <summary>
/// Protokolliert einen Würfelwurf.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt, in das protokolliert wird.</param>
/// <param name="ingame">Das TInGame-Objekt.</param>
/// <param name="ids">Die Menge der geworfenen Würfel-IDs.</param>
procedure logThrow(mmoLog: TMemo; ingame: TInGame; ids: TCubeIds);

/// <summary>
/// Protokolliert das Werfen eines Skulls .
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt.</param>
/// <param name="ingame">Das TInGame-Objekt.</param>
/// <param name="id">Die ID des Skull.</param>
procedure logFreeSkull(mmoLog: TMemo; ingame: TInGame; id: TCubeId);

/// <summary>
/// Protokolliert den Beginn eines Spielzugs.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt.</param>
/// <param name="ingame">Das TInGame-Objekt.</param>
procedure logStartMove(mmoLog: TMemo; ingame: TInGame);

/// <summary>
/// Protokolliert das Ende eines Spielzugs.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt.</param>
/// <param name="ingame">Das TInGame-Objekt.</param>
procedure logEndMove(mmoLog: TMemo; ingame: TInGame);

/// <summary>
/// Protokolliert das Ende des Spiels und den Gewinner.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt.</param>
/// <param name="ingame">Das TInGame-Objekt.</param>
procedure logWin(mmoLog: TMemo; ingame: TInGame);

/// <summary>
/// Protokolliert das Sichern eines Würfels.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt.</param>
/// <param name="ingame">Das TInGame-Objekt.</param>
/// <param name="id">Die ID des gesicherten Würfels.</param>
procedure logSaveCube(mmoLog: TMemo; ingame: TInGame; id: TCubeId);

/// <summary>
/// Protokolliert das Ablegen eines Würfels auf dem Spielbrett (nicht mehr gesichert).
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt.</param>
/// <param name="ingame">Das TInGame-Objekt.</param>
/// <param name="id">Die ID des abgelegten Würfels.</param>
procedure logFreeCube(mmoLog: TMemo; ingame: TInGame; id: TCubeId);

/// <summary>
/// Protokolliert das Sichern eines Würfels auf der Schatzinsel.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt.</param>
/// <param name="ingame">Das TInGame-Objekt.</param>
/// <param name="id">Die ID des gesicherten Würfels.</param>
procedure logSaveSavedCube(mmoLog: TMemo; ingame: TInGame; id: TCubeId);

/// <summary>
/// Protokolliert eine aufgetretene Exception.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt.</param>
/// <param name="E">Die aufgetretene Exception.</param>
procedure logException(mmoLog: TMemo; E: Exception);

implementation

uses
  System.StrUtils;

/// <summary>
/// Fügt eine Zeile zum Log-Memo hinzu.
/// </summary>
/// <param name="mmoLog">Das TMemo-Objekt.</param>
/// <param name="str">Der hinzuzufügende Text.</param>
procedure addLines(mmoLog: TMemo; str: string);
var
  rtValue: integer;
begin
  rtValue := mmoLog.Lines.Add(str);
end;

procedure logStartGame(mmoLog: TMemo; ingame: TInGame);
begin
  mmoLog.Clear;
  addLines(mmoLog, 'Neues Spiel Gestartet');
  addLines(mmoLog, 'Es nehmen ' + IntToStr(ingame.getActivePlayers) + ' Spieler teil');
  logStartMove(mmoLog, ingame);
end;

procedure logLoadGame(mmoLog: TMemo; ingame: TInGame; fName: string);
begin
  mmoLog.Clear;
  addLines(mmoLog, 'Ein Spiel wurde geladen: ' + fName);
  addLines(mmoLog, 'Es nehmen ' + IntToStr(ingame.getActivePlayers) + ' Spieler teil');
  logStartMove(mmoLog, ingame);
end;

procedure logSaveGame(mmoLog: TMemo; ingame: TInGame; fName: string);
begin
  addLines(mmoLog, 'Das Spiel wurde gespeichert: ' + fName);
end;

procedure logThrow(mmoLog: TMemo; ingame: TInGame; ids: TCubeIds);
var
  id: TCubeId;
  str: string;
begin
  str := '';

  for id in ALL_CUBE_IDS do
    if str = '' then
      str := str + IntToStr(id) + ':' + IfThen(id in ids, CUBE_SIDE_SHORTS[ingame.getCubeSide(id)], '---')
    else
      str := str + ', ' + IntToStr(id) + ':' + IfThen(id in ids, CUBE_SIDE_SHORTS[ingame.getCubeSide(id)], '---');

  addLines(mmoLog, 'würfeln: ' + str);

  if (ingame.getNumberOfThrows = 1) and (ingame.getMoveMode = mmSkullIsland) then
    addLines(mmoLog, 'Fahrt zur Totenkopfinsel');
end;

procedure logFreeSkull(mmoLog: TMemo; ingame: TInGame; id: TCubeId);
begin
  addLines(mmoLog, 'Skull gewüfelt : ' + IntToStr(id) + ':' + CUBE_SIDE_SHORTS[ingame.getCubeSide(id)])
end;

procedure logStartMove(mmoLog: TMemo; ingame: TInGame);
begin
  addLines(mmoLog, ingame.getCurrentPlayer.name + ' ist am Zug');
  addLines(mmoLog, 'Neue Karte : ' + CARD_SIDE_LONGS[ingame.getCurrentCard]);
end;

procedure logEndMove(mmoLog: TMemo; ingame: TInGame);
var
  str: string;
  id: TCubeId;
  points: integer;
begin
  points := ingame.calculatePoints;
  case ingame.getMoveMode of
    mmNormal, mmPirateShip:
      begin
        addLines(mmoLog, 'Bewertung wird durchgefürt: ' + IntToStr(points) + ' Punkte');
      end;
    mmSkullIsland:
      begin
        addLines(mmoLog, 'Ende der Fart zur TotenKopfinsel');
        addLines(mmoLog, 'Alle anderen Spieler verlieren ' + IntToStr(points * -1) + ' Punkte');
      end;
  end;
  str := '';
  for id := 0 to ingame.getActivePlayers - 1 do
    if id = 0 then
      str := str + IntToStr(ingame.getPlayerStats(id).points)
    else
      str := str + '/' + IntToStr(ingame.getPlayerStats(id).points);

  addLines(mmoLog, str);
end;

procedure logWin(mmoLog: TMemo; ingame: TInGame);
begin
  if ingame.getGameStatus = gsFinished then
    case ingame.getGameWinKind of
      gwNormal:
        addLines(mmoLog, 'Gewinner ist ' + ingame.getCurrentPlayer.name + ' mit: ' + IntToStr(ingame.getCurrentPlayer.points) +
          ' Punkten');
      gwNine:
        addLines(mmoLog, 'Gewinner ist ' + ingame.getCurrentPlayer.name + ' durch werfen von 9 gleichen würfeln');
    end;

end;

procedure logSaveCube(mmoLog: TMemo; ingame: TInGame; id: TCubeId);
begin
  addLines(mmoLog, 'gesichert: ' + IntToStr(id) + ':' + CUBE_SIDE_SHORTS[ingame.getCubeSide(id)])
end;

procedure logFreeCube(mmoLog: TMemo; ingame: TInGame; id: TCubeId);
begin
  addLines(mmoLog, 'auf Tisch gelegt: ' + IntToStr(id) + ':' + CUBE_SIDE_SHORTS[ingame.getCubeSide(id)])
end;

procedure logSaveSavedCube(mmoLog: TMemo; ingame: TInGame; id: TCubeId);
begin
  addLines(mmoLog, 'auf Schatzinsel gesichert: ' + IntToStr(id) + ':' + CUBE_SIDE_SHORTS[ingame.getCubeSide(id)])
end;

procedure logException(mmoLog: TMemo; E: Exception);
begin
  addLines(mmoLog, E.Message);
end;

end.

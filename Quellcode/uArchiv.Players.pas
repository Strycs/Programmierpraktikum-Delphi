{
  <summary>
  Dieses Modul implementiert die objektorientierte Verwaltung von Spielerinformationen.
  Es definiert die Struktur zur Speicherung von Spielerstatistiken und die zugehörigen
  Methoden zur Steuerung der Spielerlogik. Zudem dient es als Vergleichsbeispiel zur
  prozeduralen Endlösung in "uInGame.Players" und bildet die ursprüngliche Klassen-Umsetzung
  der Spieler ab.
  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
  <version>1.0</version>
  <remarks></remarks>
}

unit uArchiv.Players;

interface

uses
  uBase;

type
  /// <summary>
  /// Struktur zur Speicherung der Spielerstatistik.
  /// </summary>
  TPlayerStat = record
    name: string;
    Points: integer;
  end;

  TAllStats = array [TPlayerId] of TPlayerStat;

  TPlayers = class
  private
    allStats: TAllStats;
    numberOfActivePlayers: TActivePlayers;
    currentPlayerId: TPlayerId;

  public
    /// <summary>
    /// Lädt Spielerdaten.
    /// Initialisiert die Spielerliste mit den übergebenen Statistiken,
    /// der Anzahl der Spieler und der ID des aktuellen Spielers.
    /// </summary>
    /// <param name="statsOutside">Externe Spielerstatistiken, die geladen werden sollen.</param>
    /// <param name="numberOfPlayers">Anzahl der aktiven Spieler.</param>
    /// <param name="currentPlayerId">ID des Spielers, der als aktueller Spieler gesetzt werden soll. Optional, Standardwert ist 0.</param>
    procedure loadPlayers(statsOutside: TAllStats; numberOfPlayers: TActivePlayers; currentPlayerId: TPlayerId = 0);

    /// <summary>
    /// Setzt den aktuellen Spieler auf den nächsten Spieler.
    /// Wenn der aktuelle Spieler der letzte Spieler ist, wird der aktuelle Spieler auf den ersten Spieler gesetzt.
    /// </summary>
    procedure nextPlayer;

    /// <summary>
    /// Gibt die Statistik des aktuellen Spielers zurück.
    /// </summary>
    /// <returns>Statistik des aktuellen Spielers.</returns>
    function getCurrentPlayer: TPlayerStat;

    /// <summary>
    /// Gibt die ID des aktuellen Spielers zurück.
    /// </summary>
    /// <returns>ID des aktuellen Spielers.</returns>
    function getCurrentPlayerId: TPlayerId;

    /// <summary>
    /// Gibt die Anzahl der aktiven Spieler zurück.
    /// </summary>
    /// <returns>Anzahl der aktiven Spieler.</returns>
    function getActivePlayers: TActivePlayers;

    /// <summary>
    /// Gibt die Statistik eines bestimmten Spielers zurück.
    /// </summary>
    /// <returns>Statistik von Spieler.</returns>
    function getPlayerStats(id: TPlayerId): TPlayerStat;

    /// <summary>
    /// Aktualisiert den Punktestand eines Spielers.
    /// </summary>
    /// <param name="id">ID des Spielers, dessen Punktestand aktualisiert werden soll.</param>
    /// <param name="Points">Punkte, die dem Punktestand des Spielers hinzugefügt werden sollen.</param>
    procedure updateScore(id: TPlayerId; Points: integer);
  end;

implementation

procedure TPlayers.loadPlayers(statsOutside: TAllStats; numberOfPlayers: TActivePlayers; currentPlayerId: TPlayerId);
begin
  numberOfActivePlayers := numberOfPlayers;
  allStats := statsOutside;
  self.currentPlayerId := currentPlayerId;
end;

procedure TPlayers.nextPlayer;
begin
  if currentPlayerId = numberOfActivePlayers - 1 then
    currentPlayerId := low(TPlayerId)
  else
    inc(currentPlayerId);
end;

function TPlayers.getCurrentPlayer: TPlayerStat;
begin
  getCurrentPlayer := getPlayerStats(currentPlayerId);
end;

function TPlayers.getCurrentPlayerId: TPlayerId;
begin
  getCurrentPlayerId := currentPlayerId;
end;

function TPlayers.getActivePlayers: TActivePlayers;
begin
  getActivePlayers := numberOfActivePlayers;
end;

function TPlayers.getPlayerStats(id: TPlayerId): TPlayerStat;
begin
  assert(id < numberOfActivePlayers, 'Error invalid player id');
  getPlayerStats := allStats[id];
end;

procedure TPlayers.updateScore(id: TPlayerId; Points: integer);
begin
  allStats[id].Points := allStats[id].Points + Points;
end;

end.

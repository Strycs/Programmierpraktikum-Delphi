{
	<summary>
	Diese Unit stellt die Player-Logik bereit.
	Diese ist nicht in Form einer Klasse implementiert.
	Diese ist komplett gekapselt.
	</summary>
	<author>Morten Schobert</author>
	<created>18.03.2025</created>
}
unit uInGame.Players;

interface

uses
	uBase, SysUtils;

type
	PPlayers = pointer;

	/// <summary>
	/// Struktur zur Speicherung der Spielerstatistik.
	/// </summary>
	TPlayerStat = record
		name: string;
		Points: integer;
	end;

	TAllStats = array [TPlayerId] of TPlayerStat;
	/// <summary>
	/// Erstellt ein lenearen Speicherbereich (proceduale Version).
	/// </summary>
	/// <returns>Zeiger auf den neu erstellten Speicherbereich.</returns>
function createPlayers: PPlayers;

/// <summary>
/// Lädt Spielerdaten in den speicherbereich (proceduale Version).
/// Initialisiert die Spielerliste mit den übergebenen Statistiken,
/// der Anzahl der Spieler und der ID des aktuellen Spielers.
/// </summary>
/// <param name="me">Zeiger auf den Speicherbereich.</param>
/// <param name="statsOutside">Externe Spielerstatistiken, die geladen werden sollen.</param>
/// <param name="numberOfPlayers">Anzahl der aktiven Spieler.</param>
/// <param name="aCurrentPlayerId">ID des Spielers, der als aktueller Spieler gesetzt werden soll. Optional, Standardwert ist 0.</param>
procedure loadPlayers(me: PPlayers; statsOutside: TAllStats; numberOfPlayers: TActivePlayers;
	aCurrentPlayerId: TPlayerId = 0);

/// <summary>
/// Setzt den aktuellen Spieler auf den nächsten Spieler (proceduale Version).
/// Wenn der aktuelle Spieler der letzte Spieler ist,
/// wird der aktuelle Spieler auf den ersten Spieler gesetzt.
/// </summary>
/// <param name="me">Zeiger auf den Speicherbereich.</param>
procedure nextPlayer(me: PPlayers);

/// <summary>
/// Gibt die Statistik des aktuellen Spielers zurück (proceduale Version).
/// </summary>
/// <param name="me">Zeiger auf den Speicherbereich.</param>
/// <returns>Statistik des aktuellen Spielers.</returns>
function getCurrentPlayer(me: PPlayers): TPlayerStat;

/// <summary>
/// Gibt die ID des aktuellen Spielers zurück (proceduale Version).
/// </summary>
/// <param name="me">Zeiger auf den Speicherbereich.</param>
/// <returns>ID des aktuellen Spielers.</returns>
function getCurrentPlayerId(me: PPlayers): TPlayerId;

/// <summary>
/// Gibt die Anzahl der aktiven Spieler zurück (proceduale Version).
/// </summary>
/// <param name="me">Zeiger auf den Speicherbereich.</param>
/// <returns>Anzahl der aktiven Spieler.</returns>
function getActivePlayers(me: PPlayers): TActivePlayers;

/// <summary>
/// Gibt die Statistik eines Spielers anhand seiner ID zurück (proceduale Version).
/// </summary>
/// <param name="me">Zeiger auf den Spiecherbereich.</param>
/// <param name="id">ID des Spielers, dessen Statistik angefordert wird.</param>
/// <returns>Statistik des angeforderten Spielers.</returns>
function getPlayerStats(me: PPlayers; id: TPlayerId): TPlayerStat;

/// <summary>
/// Aktualisiert den Punktestand eines Spielers (proceduale Version).
/// </summary>
/// <param name="me">Zeiger auf den Speicherbereich.</param>
/// <param name="id">ID des Spielers, dessen Punktestand aktualisiert werden soll.</param>
/// <param name="Points">Punkte, die dem Punktestand des Spielers hinzugefügt werden sollen.</param>
procedure updateScore(me: PPlayers; id: TPlayerId; Points: integer);

/// <summary>
/// Gibt den in createPlayers resavierten Speicher wieder frei (proceduale Version).
/// Setzt den übergebenen Zeiger nach der Freigabe auf nil.
/// </summary>
/// <param name="me">Referenz auf den Zeiger der auf den Speicherbereich der spiel verweist.</param>
procedure freePlayers(var me: PPlayers);

/// <summary>
/// Fügt Namen und Punkte in eine zurückgegebende struktur ein.
/// </summary>
/// <param name="name">Name des Spielers.</param>
/// <param name="Points">Startpunktestand des Spielers. Optional, Standardwert ist 0.</param>
/// <returns>Neu erstellte Spielerstatistik-Struktur.</returns>
function Player(name: string; Points: integer = 0): TPlayerStat;

implementation

uses
	uMemCounter, Dialogs;

type
	PPlayersRec = ^TPlayersRec;

	TPlayersRec = record
		allStats: TAllStats;
		numberOfActivePlayers: TActivePlayers;
		currentPlayerId: TPlayerId;
	end;

function Player(name: string; Points: integer = 0): TPlayerStat;
begin
	Player.name := name;
	Player.Points := Points;
end;

function createPlayers: PPlayers;
var
	playersRecPtr: PPlayersRec;
begin

	playersRecPtr := createMemory(sizeOf(TPlayersRec));
	Initialize(playersRecPtr^);

	with playersRecPtr^ do
	begin
		currentPlayerId := 0;
		allStats[0] := Player('#1');
		allStats[1] := Player('#2');
		allStats[2] := Player('#3');
		allStats[3] := Player('#4');
		numberOfActivePlayers := 4;
	end;

	createPlayers := playersRecPtr;
end;

procedure freePlayers(var me: PPlayers);
var
	playersRecPtr: PPlayersRec;

begin
	playersRecPtr := PPlayersRec(me);
	Finalize(playersRecPtr^);
	releaseInstance(me);
	me := nil;
end;

function getActivePlayers(me: PPlayers): TActivePlayers;
begin
	with PPlayersRec(me)^ do getActivePlayers := numberOfActivePlayers;
end;

function getCurrentPlayer(me: PPlayers): TPlayerStat;
begin
	with PPlayersRec(me)^ do getCurrentPlayer := getPlayerStats(me, currentPlayerId);
end;

function getCurrentPlayerId(me: PPlayers): TPlayerId;
begin
	with PPlayersRec(me)^ do getCurrentPlayerId := currentPlayerId;
end;

function getPlayerStats(me: PPlayers; id: TPlayerId): TPlayerStat;
begin
	with PPlayersRec(me)^ do
	begin
		assert(id < numberOfActivePlayers, 'Error invalid player id');
		getPlayerStats := allStats[id];
	end;
end;

procedure nextPlayer(me: PPlayers);
begin
	with PPlayersRec(me)^ do
	begin
		if currentPlayerId = numberOfActivePlayers - 1 then currentPlayerId := low(TPlayerId)
		else inc(currentPlayerId);
	end;
end;

procedure updateScore(me: PPlayers; id: TPlayerId; Points: integer);
begin
	with PPlayersRec(me)^ do allStats[id].Points := allStats[id].Points + Points;
end;

procedure loadPlayers(me: PPlayers; statsOutside: TAllStats; numberOfPlayers: TActivePlayers;
	aCurrentPlayerId: TPlayerId);
begin
	with PPlayersRec(me)^ do
	begin
		numberOfActivePlayers := numberOfPlayers;
		allStats := statsOutside;
		currentPlayerId := aCurrentPlayerId;
	end;
end;

end.

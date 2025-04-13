{
	<summary>
	Hier wird die eigentliche Spiellogik implementiert.
	Kern ist die Klasse TInGame
	</summary>
	<author>Morten Schobert</author>
	<created>18.03.2025</created>
}
unit uInGame;

interface

uses
	SysUtils,
	Classes,
	uInGame.Players,
	uInGame.Cubes,
	uInGame.Cards,
	uBase;

type

	/// <summary>
	/// Definiert die m�glichen Aktionen im Spiel.
	/// </summary>
	TAction = (gaSaveCube, gaSaveSavedCube, gaFreeCube, gaFreeSkull, gaThrow, gaEndMove, gaNextMove, gaWaitForGame,
		gaSaveGame, gaStartGame, gaLoadGame);

	/// <summary>
	/// Menge der m�glichen Aktionen.
	/// </summary>
	TActions = set of TAction;

	/// <summary>
	/// Definiert den Status des Spiels.
	/// </summary>
	TGameStatus = (gsWaiting, gsRunning, gsFinished);

	/// <summary>
	/// Definiert den Status eines Zuges.
	/// </summary>
	TMoveStatus = (msInMove, msEndMoveRequired, msNotInMove);

	/// <summary>
	/// Definiert die Art des Spielgewinns.
	/// </summary>
	TGameWinkind = (gwNone, gwNormal, gwNine);

	/// <summary>
	/// Hauptklasse f�r die Spiel-Logik InGame.
	/// Verwaltet das Spielgeschehen, Spieler, W�rfel und Karten.
	/// </summary>
	TInGame = class
	strict private
		Cubes: TGameCubes;
		Players: PPlayers;
		CardStack: TCardStack;
		CurrentCardId: TCardId;
		GameStatus: TGameStatus;
		GameWinKind: TGameWinkind;
		NumberOfMoves: integer;
		MoveMode: TMoveMode;
		MoveStatus: TMoveStatus;

		/// <summary>
		/// Anzahl der w�rfe im aktuellen Zug, wird ben�tigt f�r
		/// das steuern ob zur Totenkofinsel gefaren wird.
		/// </summary>
		NumberOfThrows: integer;

		/// <summary>
		/// Anzahl der befreiten Sch�del im aktuellen Zug,
		/// wird ben�tigt f�r die logik der W�chterinen Karte.
		/// </summary>
		NumberOfFreedSkulls: integer;

		/// <summary>
		/// Anzahl der Sch�del im aktuellen Wurf,wird
		/// ben�tigt f�r die Abbruch-logik der Totenkopfinsel.
		/// </summary>
		NumberOfSkullsInThrow: TNumberOfCubes;
		lastFileName: string;

		/// <summary>
		/// Speichert ob der Cheat Modus aktiviert ist (Aktivierung: ALT + c).
		/// </summary>
		cheatMode: Boolean;

		/// <summary>
		/// Pr�ft, ob ein Zugende notwendig ist, falls Sch�del-Limit �berschritten.
		/// </summary>
		/// <returns>True, wenn ein Zugende notwendig ist, sonst False.</returns>
		function isEndMoveNecessary: Boolean;

		/// <summary>
		/// Pr�ft, ob das Spiel beendet ist.
		/// </summary>
		/// <returns>True, wenn das Spiel beendet ist, sonst False.</returns>
		function testFinishGame: Boolean;

		/// <summary>
		/// Startet einen neuen Zug.
		/// Initialisiert Variablen f�r einen neuen Spielerzug.
		/// </summary>
		procedure startMove;

		/// <summary>
		/// Gibt die Aktionen, die man speziel im
		/// Normalen/Piratenschiff modus tuen darf zur�ck.
		/// </summary>
		/// <returns>Menge der normalen Aktionen (TActions).</returns>
		function getNormalActions: TActions;

		/// <summary>
		/// Gibt die Aktionen, die man speziel im Totenkopfinsel Modus tuen darf zur�ck.
		/// </summary>
		/// <returns>Menge der Sch�delinsel-Aktionen (TActions).</returns>
		function getSkullIslandActions: TActions;
	public

		/// <summary>
		/// wird nach dem create der Classe ausgef�rt.
		/// Initialisiert das Spiel, erstellt Spieler und W�rfel und ruft waitForGame auf .
		/// </summary>
		procedure afterConstruction; override;

		/// <summary>
		/// Initialisiert das Spiel im Warte-Status.
		/// </summary>
		procedure waitForGame;

		/// <summary>
		/// Destruktor f�r TInGame-Objekt.
		/// Gibt Ressourcen frei, einschlie�lich W�rfel und Spieler.
		/// </summary>
		destructor destroy; override;

		/// <summary>
		/// Gibt den aktuellen Spielstatus zur�ck.
		/// </summary>
		/// <returns>Aktueller Spielstatus (TGameStatus).</returns>
		function getGameStatus: TGameStatus;

		/// <summary>
		/// Gibt die Art des Spielgewinns zur�ck .
		/// </summary>
		/// <returns>Art des Spielgewinns (TGameWinkind).</returns>
		function getGameWinKind: TGameWinkind;

		/// <summary>
		/// Gibt die aktuell aufgedeckte Karte zur�ck.
		/// </summary>
		/// <returns>Aktuelle Spielkarte (TGameCard).</returns>
		function getCurrentCard: TGameCard;

		/// <summary>
		/// Gibt die Statistik des aktuellen Spielers zur�ck.
		/// </summary>
		/// <returns>Statistik des aktuellen Spielers (TPlayerStat).</returns>
		function getCurrentPlayer: TPlayerStat;

		/// <summary>
		/// Gibt die Anzahl der aktiven Spieler zur�ck.
		/// </summary>
		/// <returns>Anzahl der aktiven Spieler (TActivePlayers).</returns>
		function getActivePlayers: TActivePlayers;

		/// <summary>
		/// Gibt die ID des aktuellen Spielers zur�ck.
		/// </summary>
		/// <returns>ID des aktuellen Spielers (TPlayerId).</returns>
		function getCurrentPlayerId: TPlayerId;

		/// <summary>
		/// Gibt die Statistik eines bestimmten Spielers anhand seiner ID zur�ck.
		/// </summary>
		/// <param name="id">ID des Spielers, dessen Statistik abgefragt wird.</param>
		/// <returns>Statistik des angeforderten Spielers (TPlayerStat).</returns>
		function getPlayerStats(id: TPlayerId): TPlayerStat;

		/// <summary>
		/// Gibt den aktuellen Zug Modus zur�ck.
		/// </summary>
		/// <returns>Aktueller Zug-Modus (TMoveMode).</returns>
		function getMoveMode: TMoveMode;

		/// <summary>
		/// Gibt den aktuellen Zug-Status zur�ck.
		/// </summary>
		/// <returns>Aktueller Zug-Status (TMoveStatus).</returns>
		function getMoveStatus: TMoveStatus;

		/// <summary>
		/// Gibt alle m�glichen Aktionen im aktuellen Spielzustand zur�ck.
		/// </summary>
		/// <returns>Menge der m�glichen Aktionen (TActions).</returns>
		function getPossibleActions: TActions;

		/// <summary>
		/// Gibt alle m�glichen Aktionen f�r einen bestimmten W�rfel im aktuellen Spielzustand zur�ck.
		/// </summary>
		/// <param name="id">ID des W�rfels, dessen m�gliche Aktionen abgefragt werden.</param>
		/// <returns>Menge der m�glichen W�rfel-Aktionen (TActions).</returns>
		function getPossibleCubeActions(id: TCubeId): TActions;

		/// <summary>
		/// Gibt die IDs der W�rfel zur�ck, die sich in den angegebene Zust�nden befinden.
		/// </summary>
		/// <param name="states">Menge der W�rfelzust�nde, f�r die die IDs zur�ckgegeben werden sollen.</param>
		/// <returns>Menge der W�rfel-IDs (TCubeIdSet).</returns>
		function getCubeIds(states: TCubeStates): TCubeIds;

		/// <summary>
		/// Gibt die aktuelle Seite eines bestimmten W�rfels zur�ck.
		/// </summary>
		/// <param name="id">ID des W�rfels, dessen Seite abgefragt wird.</param>
		/// <returns>Aktuelle Seite des W�rfels (TCubeSide).</returns>
		function getCubeSide(id: TCubeId): TCubeSide;

		/// <summary>
		/// Gibt die Anzahl der W�rfelw�rfe im aktuellen Zug zur�ck.
		/// </summary>
		/// <returns>Anzahl der W�rfelw�rfe (Integer).</returns>
		function getNumberOfThrows: integer;

		/// <summary>
		/// Startet ein neues Spiel.
		/// Initialisiert Spieler, Kartenstapel und beginnt den ersten Zug.
		/// </summary>
		/// <param name="playerNames">Array der Spielernamen.</param>
		/// <param name="numberOfPlayers">Anzahl der Spieler.</param>
		/// <param name="pCardStack">[Optional=nil] Optionaler Kartenstapel f�r Testzwecke.</param>
		procedure start(const playerNames: TPlayerNames; numberOfPlayers: TActivePlayers; pCardStack: pCardStack = nil);

		/// <summary>
		/// L�dt ein Spiel aus einer Datei.
		/// </summary>
		/// <param name="fileName">Pfad und Dateiname der Speicherdatei.</param>
		procedure loadGame(fileName: string);

		/// <summary>
		/// Speichert den aktuellen Spielzustand in einer Datei.
		/// </summary>
		/// <param name="fileName">Pfad und Dateiname f�r die Speicherdatei.</param>
		procedure saveGame(fileName: string);

		/// <summary>
		/// liefert den zuletzt benutzen Filename
		/// </summary>
		function getLastFileName: string;

		/// <summary>
		/// Gibt zur�ck ob der cheat Modus aktiviert ist
		/// </summary>
		function getCheatMode: Boolean;

		/// <summary>
		/// Setzt den cheat Modus
		/// </summary>
		procedure setCheatMode(status: Boolean);

		/// <summary>
		/// Startet den n�chsten Zug des Spiels.
		/// Geht zum n�chsten Spieler �ber und deckt ggf. eine neue Karte auf.
		/// </summary>
		procedure nextMove;

		/// <summary>
		/// Beendet den aktuellen Zug des Spielers.
		/// Wertet den Zug aus und aktualisiert die Punkte.
		/// </summary>
		procedure endMove;

		/// <summary>
		/// Setzt einen W�rfel vom gesicherten oder gesichertGescherten Zustand auf den freien Zustand.
		/// </summary>
		/// <param name="id">ID des W�rfels, der freigegeben werden soll.</param>
		procedure freeCube(id: TCubeId);

		/// <summary>
		/// Setzt einen freien W�rfel in den gesicherten Zustand.
		/// </summary>
		/// <param name="id">ID des zu sichernden W�rfels.</param>
		procedure saveCube(id: TCubeId);

		/// <summary>
		/// Setzt einen freien W�rfel in den gesichertgesicherten Zustand,
		/// nur bei Schatzinsel  Karte m�glich.
		/// </summary>
		/// <param name="id">ID des zu rettenden W�rfels.</param>
		procedure saveSavedCube(id: TCubeId);

		/// <summary>
		/// Wirft die freien W�rfel.
		/// Aktualisiert die W�rfelzust�nde basierend auf den W�rfelergebnissen.
		/// </summary>
		/// <param name="pSideArray">[Optional=nil] Optionales Array f�r vorherbestimmte W�rfelergebnisse f�r Testzwecke.</param>
		procedure throwCubes(ptrCubeIdSides: PCubeIdSides = nil);

		/// <summary>
		/// Wirft einen einzelnen Totenkopfw�rfel neu.
		/// Wird f�r die Guardian-Karte verwendet.
		/// </summary>
		/// <param name="id">ID des Sch�delw�rfels, der neu geworfen werden soll.</param>
		procedure throwSkull(id: TCubeId);

		/// <summary>
		/// Berechnet die Punkte, die im aktuellen Zug erzielt wurden.
		/// </summary>
		/// <returns>Erzielte Punkte (Integer).</returns>
		function calculatePoints: integer;

	end;

implementation

uses uInGame.internal, uInGame.IO, uMemCounter;
{ TInGame }

function TInGame.calculatePoints: integer;
begin
	if (GameStatus = gsWaiting) or (NumberOfThrows = 0) then
	begin
		calculatePoints := 0;
	end
	else calculatePoints := moveCalculatePoints(Cubes, getCurrentCard, MoveMode);
end;

procedure TInGame.afterConstruction;
begin
	inherited; // Calls TObject.AfterConstruction (does nothing by default)
	Cubes := createObject(TGameCubes) as TGameCubes;

	Players := createPlayers;

	lastFileName := '';
	waitForGame;
end;

destructor TInGame.destroy;
begin
	releaseInstance(Cubes);

	freePlayers(Players);
	inherited destroy;
end;

procedure TInGame.waitForGame;
begin
	GameStatus := gsWaiting;

	cheatMode := false;
	// running Game Variables
	GameWinKind := gwNone;
	NumberOfMoves := 0;
	CurrentCardId := 0;

	NumberOfFreedSkulls := 0;
	NumberOfThrows := 0;
	NumberOfSkullsInThrow := 0;
	Cubes.initCubes;
end;

procedure TInGame.start(const playerNames: TPlayerNames; numberOfPlayers: TActivePlayers; pCardStack: pCardStack);
var
	starterStats: TAllStats;
	i: TPlayerId;
begin
	GameStatus := gsRunning;
	GameWinKind := gwNone;
	NumberOfMoves := 0;
	CurrentCardId := 0;

	for i := 0 to numberOfPlayers - 1 do starterStats[i] := player(playerNames[i]);

	loadPlayers(Players, starterStats, numberOfPlayers);

	if not Assigned(pCardStack) then CardStack := getShuffledCardStack
	else CardStack := pCardStack^; // for testing

	startMove;
end;

procedure TInGame.startMove;
begin
	inc(NumberOfMoves);

	NumberOfFreedSkulls := 0;
	NumberOfThrows := 0;
	NumberOfSkullsInThrow := 0;
	Cubes.initCubes;

	if getCurrentCard in ALL_PIRATESHIPS then MoveMode := mmPirateShip
	else MoveMode := mmNormal;

	MoveStatus := msInMove;
end;

procedure TInGame.nextMove;
begin
	assert(GameStatus = gsRunning, 'Error game is not running');

	if MoveStatus = msNotInMove then
	begin
		nextPlayer(Players);

		if CurrentCardId = high(TCardId) then CurrentCardId := low(TCardId)
		else inc(CurrentCardId);

		startMove;
	end;
end;

function TInGame.getGameWinKind: TGameWinkind;
begin
	getGameWinKind := GameWinKind;
end;

function TInGame.getLastFileName: string;
begin
	getLastFileName := lastFileName;
end;

procedure TInGame.throwCubes(ptrCubeIdSides: PCubeIdSides);
var
	throwables: TCubeIds;
begin

	if not Assigned(ptrCubeIdSides) then
	begin
		throwables := Cubes.getCubeIds([ctFree]);
		Cubes.throwCubes(throwables);
	end
	else
	begin // for testing and cheating
		throwables := ptrCubeIdSides^.ids;
		inc(NumberOfFreedSkulls, numberOf(Cubes.getCubeIds([ctKilled]) * throwables));

		Cubes.throwCubes(ptrCubeIdSides^);
	end;

	NumberOfSkullsInThrow := numberOf(throwables * Cubes.getCubeIds([ctKilled])); // SchnittMenge

	inc(NumberOfThrows);

	// if MoveMode <> mmPirateShip then
	if (NumberOfThrows = 1) and (numberOf(Cubes.getCubeIds([ctKilled])) + additionalCubeSidesFrom(getCurrentCard, csSkull)
		>= MIN_SKULLS_FOR_SKULL_ISLAND_MOVE) then
	begin
		MoveMode := mmSkullIsland;
	end;

	if not testFinishGame then
		if isEndMoveNecessary then MoveStatus := msEndMoveRequired
end;

procedure TInGame.throwSkull(id: TCubeId);
begin
	assert(gaFreeSkull in getPossibleCubeActions(id), 'Error Throw skull');

	Cubes.throwCubes([id]);

	inc(NumberOfFreedSkulls);

	if not testFinishGame then
		if isEndMoveNecessary then MoveStatus := msEndMoveRequired

end;

procedure TInGame.endMove;
var
	id: TPlayerId;
	points: integer;
	isFinished: Boolean;
begin
	MoveStatus := msNotInMove;

	points := calculatePoints;
	case MoveMode of
		{ TODO -oMS -cISSUE : man bekommt punkte auch bei normal loose }
		mmNormal, mmPirateShip:
			updateScore(Players, getCurrentPlayerId, points);
		mmSkullIsland:
			for id := 0 to getActivePlayers - 1 do
				if id <> getCurrentPlayerId then updateScore(Players, id, points);
	end;
	isFinished := testFinishGame;
end;

procedure TInGame.saveCube(id: TCubeId);
begin
	Cubes.setCubeState(id, ctSaved);
end;

procedure TInGame.saveGame(fileName: string);
	function mapCardStack(const CardStack: TCardStack): TCardStack;
	var
		id: TCardId;
	begin
		for id := 0 to NUMBER_OF_CARDS - 1 do
				mapCardStack[(id + NUMBER_OF_CARDS - CurrentCardId) mod NUMBER_OF_CARDS] := CardStack[id];
	end;

var
	gameStructure: TGameStructure;
	err: TIngameIOError;
	id: TPlayerId;
begin
	lastFileName := fileName;
	gameStructure.numberOfPlayers := getActivePlayers;
	gameStructure.currentPlayerId := getCurrentPlayerId;
	for id := 0 to getActivePlayers - 1 do gameStructure.playerStats[id] := getPlayerStats(id);

	gameStructure.CardStack := mapCardStack(CardStack);

	err := saveToFile(fileName, gameStructure);
	if err.code <> ERR_NO_ERROR then
			raise Exception.CreateFmt('saveGameError code: %d at line: %d', [err.code, err.line]);
end;

procedure TInGame.saveSavedCube(id: TCubeId);
begin
	Cubes.setCubeState(id, ctSaveSaved);
end;

procedure TInGame.setCheatMode(status: Boolean);
begin
	cheatMode := status;
end;

procedure TInGame.freeCube(id: TCubeId);
begin
	// freeCube := Cubes.getCubeState(id); // to know the old state in the ui ctSaved/ctSaveSaved
	Cubes.setCubeState(id, ctFree);
end;

function TInGame.getNormalActions: TActions;
var
	actions: TActions;
begin
	actions := [];
	if MoveStatus = msEndMoveRequired then include(actions, gaEndMove)
	else
	begin
		if (MoveMode <> mmPirateShip) or
			(PIRATESHIP_SABERS[getCurrentCard] <= numberOf(Cubes.getCubeIds(ctNOTKILLED, [csSaber]))) then
			if numberOf(getCubeIds([ctKilled])) < MIN_SKULLS_FOR_LOST_MOVE then include(actions, gaEndMove);

		if numberOf(Cubes.getCubeIds([ctFree])) >= MIN_CUBES_FOR_THROW then include(actions, gaThrow);

		if numberOf(Cubes.getCubeIds(ctALLSAVED)) <> 0 then include(actions, gaFreeCube);

		if numberOf(Cubes.getCubeIds([ctFree])) <> 0 then include(actions, gaSaveCube);

		if (getCurrentCard = gcGuardian) and (NumberOfFreedSkulls = 0) then include(actions, gaFreeSkull);

		if getCurrentCard = gcTreasureIsland then
		begin
			if numberOf(Cubes.getCubeIds([ctFree])) <> 0 then include(actions, gaSaveSavedCube);
		end;
	end;
	getNormalActions := actions;
end;

function TInGame.getSkullIslandActions: TActions;
var
	actions: TActions;
begin
	actions := [];
	if MoveStatus = msEndMoveRequired then include(actions, gaEndMove)
	else include(actions, gaThrow);

	getSkullIslandActions := actions;
end;

function TInGame.isEndMoveNecessary: Boolean;
var
	numberOfSkulls: integer; // because max is 8+2
	rslt: Boolean;
begin
	rslt := false;
	if MoveStatus = msInMove then
	begin
		numberOfSkulls := (numberOf(Cubes.getCubeIds([ctKilled]))) + additionalCubeSidesFrom(getCurrentCard, csSkull);
		case MoveMode of
			mmNormal, mmPirateShip:
				begin
					if numberOfSkulls > MIN_SKULLS_FOR_LOST_MOVE then rslt := true
					else if (numberOfSkulls = MIN_SKULLS_FOR_LOST_MOVE) then
						if (getCurrentCard <> gcGuardian) or (NumberOfFreedSkulls > 0) then rslt := true;
				end;
			mmSkullIsland:
				begin
					rslt := NumberOfSkullsInThrow = 0;
				end;
		end;
	end;
	isEndMoveNecessary := rslt;
end;

function TInGame.testFinishGame: Boolean;
begin
	if isGameWinKindNine(Cubes, getCurrentCard) then
	begin
		GameStatus := gsFinished;
		MoveStatus := msNotInMove;
		GameWinKind := gwNine;
	end
	else if getCurrentPlayer.points >= POINTS_FOR_WIN then
	begin
		GameStatus := gsFinished;
		MoveStatus := msNotInMove;
		GameWinKind := gwNormal;
	end;
	testFinishGame := GameStatus = gsFinished;
end;

procedure TInGame.loadGame(fileName: string);
var
	gameStructure: TGameStructure;
	err: TIngameIOError;
begin
	lastFileName := fileName;
	err := loadFromFile(fileName, gameStructure);
	if err.code <> ERR_NO_ERROR then
			raise Exception.CreateFmt('loadgameError code: %d at line: %d in %s', [err.code, err.line, fileName]);

	if err.code = ERR_NO_ERROR then
	begin
		GameStatus := gsRunning;
		NumberOfMoves := 0;

		loadPlayers(Players, gameStructure.playerStats, gameStructure.numberOfPlayers, gameStructure.currentPlayerId);

		CurrentCardId := 0;
		CardStack := gameStructure.CardStack;

		startMove;
	end;
end;

function TInGame.getActivePlayers: TActivePlayers;
begin
	{ TODO -oMS -cRefactor : naming is not in sync }
	getActivePlayers := uInGame.Players.getActivePlayers(Players);
end;

function TInGame.getCheatMode: Boolean;
begin
	getCheatMode := cheatMode;
end;

function TInGame.getCubeIds(states: TCubeStates): TCubeIds;
begin
	getCubeIds := Cubes.getCubeIds(states);
end;

function TInGame.getCubeSide(id: TCubeId): TCubeSide;
begin
	getCubeSide := Cubes.getCubeSide(id);
end;

function TInGame.getCurrentCard: TGameCard;
begin
	getCurrentCard := CardStack[CurrentCardId];
end;

function TInGame.getCurrentPlayer: TPlayerStat;
begin
	getCurrentPlayer := uInGame.Players.getCurrentPlayer(Players);
end;

function TInGame.getCurrentPlayerId: TPlayerId;
begin
	getCurrentPlayerId := uInGame.Players.getCurrentPlayerId(Players);
end;

function TInGame.getGameStatus: TGameStatus;
begin
	getGameStatus := GameStatus;
end;

function TInGame.getMoveMode: TMoveMode;
begin
	getMoveMode := MoveMode;
end;

function TInGame.getMoveStatus: TMoveStatus;
begin
	getMoveStatus := MoveStatus;
end;

function TInGame.getNumberOfThrows: integer;
begin
	getNumberOfThrows := NumberOfThrows;
end;

function TInGame.getPlayerStats(id: TPlayerId): TPlayerStat;
begin
	getPlayerStats := uInGame.Players.getPlayerStats(Players, id);
end;

function TInGame.getPossibleActions: TActions;
var
	actions: TActions;
begin
	actions := [gaWaitForGame, gaStartGame, gaLoadGame];
	if GameStatus = gsRunning then
	begin
		if MoveStatus = msNotInMove then actions := [gaNextMove]
		else
		begin
			if NumberOfThrows = 0 then
			begin
				include(actions, gaThrow);
				include(actions, gaSaveGame);
			end
			else
				case MoveMode of
					mmNormal, mmPirateShip:
						actions := actions + getNormalActions;
					mmSkullIsland:
						actions := actions + getSkullIslandActions;
				end;
		end;
	end;
	getPossibleActions := actions;
end;

function TInGame.getPossibleCubeActions(id: TCubeId): TActions;
var
	actions: TActions;
begin
	actions := [];
	if (GameStatus = gsRunning) and (MoveStatus = msInMove) then
		if (MoveMode <> mmSkullIsland) then
		begin
			case Cubes.getCubeState(id) of
				ctFree:
					begin
						include(actions, gaSaveCube);

						if getCurrentCard = gcTreasureIsland then include(actions, gaSaveSavedCube);
					end;
				ctSaved, ctSaveSaved:
					include(actions, gaFreeCube);
				ctKilled:
					if (getCurrentCard = gcGuardian) and (NumberOfFreedSkulls = 0) then include(actions, gaFreeSkull)
			end;
		end;
	getPossibleCubeActions := actions;
end;

end.

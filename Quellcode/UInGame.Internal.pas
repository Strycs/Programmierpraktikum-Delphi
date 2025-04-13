{
	<summary>
	ist für die Berechnung der Punkte zuständig
	</summary>
	<author>Morten Schobert</author>
	<created>18.03.2025</created>
	<version>1.0</version>
	<remarks></remarks>
}
unit UInGame.Internal;

interface

uses
	uBase,
	UInGame.Cubes;

/// <summary>
/// Berechnet den Punkte für einzelne Würfelseiten in einem Zug.
/// </summary>
/// <param name="cubes">Das TGameCubesClass-Objekt, das die Würfel verwaltet.</param>
/// <param name="card">Die aktuell gespielte Karte.</param>
/// <param name="moveMode">Der aktuelle Spielmodus (mmNormal, mmSkullIsland, mmPirateShip).</param>
/// <param name="states">Die zu berücksichtigenden Würfelzustände.</param>
/// <returns>Der berechnete Punktebonus für die Würfelseiten.</returns>
function moveSideBonus(Cubes: TGameCubes; card: TGameCard; moveMode: TMoveMode; states: TCubeStates): integer;

/// <summary>
/// Berechnet den Punkte für Kombinationen von Würfelseiten in einem Zug.
/// </summary>
/// <param name="cubes">Das TGameCubesClass-Objekt, das die Würfel verwaltet.</param>
/// <param name="card">Die aktuell gespielte Karte.</param>
/// <param name="moveMode">Der aktuelle Spielmodus.</param>
/// <param name="states">Die zu berücksichtigenden Würfelzustände.</param>
/// <returns>Der berechnete Punktebonus für die Kombinationen.</returns>
function moveCombinationBonus(Cubes: TGameCubes; card: TGameCard; moveMode: TMoveMode; states: TCubeStates): integer;

/// <summary>
/// Berechnet die Gesamtpunktzahl für einen Zug.
/// </summary>
/// <param name="cubes">Das TGameCubesClass-Objekt, das die Würfel verwaltet.</param>
/// <param name="card">Die aktuell gespielte Karte.</param>
/// <param name="moveMode">Der aktuelle Spielmodus.</param>
/// <returns>Die Gesamtpunktzahl für den Zug.</returns>
function moveCalculatePoints(Cubes: TGameCubes; card: TGameCard; moveMode: TMoveMode): integer;

/// <summary>
/// Prüft, ob das Spiel durch eine "Neun Gleiche"-kombination direckt gewonnen ist.
/// </summary>
/// <param name="cubes">Das TGameCubesClass-Objekt.</param>
/// <param name="card">Die aktuell gespielte Karte.</param>
/// <returns>True, wenn das Spiel durch neun Gleiche gewonnen wurde, sonst False.</returns>
function isGameWinKindNine(Cubes: TGameCubes; card: TGameCard): boolean;

implementation

uses
	SysUtils,
	UInGame.Cards;

function isGameWinKindNine(Cubes: TGameCubes; card: TGameCard): boolean;
var
	rslt: boolean;
begin
	rslt := false;
	case card of
		gcDiamond:
			rslt := NUMBER_OF_CUBES = numberOf(Cubes.getCubeIds(ctNOTKILLED, [csDiamond]));
		gcGoldCoin:
			rslt := NUMBER_OF_CUBES = numberOf(Cubes.getCubeIds(ctNOTKILLED, [csGoldCoin]));
	end;
	isGameWinKindNine := rslt;
end;

function moveSideBonus(Cubes: TGameCubes; card: TGameCard; moveMode: TMoveMode; states: TCubeStates): integer;
var
	sides: TCubeSides;
	side: TCubeSide;
	bonus: integer;
begin
	bonus := 0;

	if moveMode = mmSkullIsland then sides := [csSkull]
	else sides := csALL - [csSkull];

	for side in sides do
	begin
		bonus := bonus + SIDE_POINTS[side] * additionalCubeSidesFrom(card, side);
		bonus := bonus + SIDE_POINTS[side] * numberOf(Cubes.getCubeIds(states, [side]));
	end;
	moveSideBonus := bonus;
end;

function moveCombinationBonus(Cubes: TGameCubes; card: TGameCard; moveMode: TMoveMode; states: TCubeStates): integer;
var
	noc: TNumberOfCubes;
	side: TCubeSide;
	sides: TCubeSides;
	isTreasureChest: boolean;
	points: integer;
begin
	points := 0;
	sides := csALL;
	isTreasureChest := false;

	if moveMode <> mmSkullIsland then
	begin
		if NUMBER_OF_CUBES = numberOf(Cubes.getCubeIds(states)) then isTreasureChest := true;

		if card in [gcSkull1, gcSkull2] then isTreasureChest := false;

		if card = gcAnimals then
		begin
			noc := numberOf(Cubes.getCubeIds(states, csANIMALS));

			points := points + COMBINATION_POINTS[noc];

			if isTreasureChest and (COMBINATION_POINTS[noc] = 0) and (noc > 0) then isTreasureChest := false;

			sides := sides - csANIMALS;
		end;

		for side in sides do
		begin
			noc := numberOf(Cubes.getCubeIds(states, [side]));

			noc := noc + additionalCubeSidesFrom(card, side);

			points := points + COMBINATION_POINTS[noc];

			if not(side in [csDiamond, csGoldCoin]) and (noc > 0) then
				if isTreasureChest and (COMBINATION_POINTS[noc] = 0) then isTreasureChest := false;
		end;
		if isTreasureChest then points := points + TREASURE_CHEST_BONUS;
	end;
	moveCombinationBonus := points;
end;

function moveCalculatePoints(Cubes: TGameCubes; card: TGameCard; moveMode: TMoveMode): integer;

{ TODO -oMS -cClarification : Fragen, ob locale Funktionen auf die globalen Aufrufparameter zugreifen dürfen, oder ob schlechter Stil? }
/// <summary>
/// Lokale Funktion zur Berechnung der Anzahl an Totenköpfen (Würfel + Karte).
/// </summary>
/// <param name="cubes">Das TGameCubesClass-Objekt.</param>
/// <param name="card">Die aktuelle Karte</param>
/// <returns>Anzahl an Totenköpfen.</returns>
	function numberOfSkulls(Cubes: TGameCubes; card: TGameCard): integer; // because max skulls are 10
	begin
		numberOfSkulls := numberOf(Cubes.getCubeIds(ctALL, [csSkull])) + additionalCubeSidesFrom(card, csSkull)
	end;

var
	points: integer;
begin
	points := 0;
	case moveMode of
		mmNormal:
			begin
				if numberOfSkulls(Cubes, card) >= MIN_SKULLS_FOR_LOST_MOVE then
				begin
					if card = gcTreasureIsland then
							points := moveCombinationBonus(Cubes, card, moveMode, [ctSaveSaved]) +
							moveSideBonus(Cubes, card, moveMode, [ctSaveSaved])
					else points := 0;
				end
				else
				begin
					points := moveCombinationBonus(Cubes, card, moveMode, ctALLSAVED) + moveSideBonus(Cubes, card, moveMode,
						ctALLSAVED);

					if card = gcPirate then points := points * 2;
				end;

			end;

		mmSkullIsland:
			begin
				assert(numberOfSkulls(Cubes, card) >= MIN_SKULLS_FOR_SKULL_ISLAND_MOVE,
					'Error: internal error not enough skulls for mmSkullIsland');

				points := moveCombinationBonus(Cubes, card, moveMode, [ctKilled]) + moveSideBonus(Cubes, card, moveMode,
					[ctKilled]);
				if card = gcPirate then points := points * 2;
			end;
		mmPirateShip:
			begin
				assert(card in ALL_PIRATESHIPS, 'Error: internal error card is not valid pirateShip');

				if PIRATESHIP_SABERS[card] > numberOf(Cubes.getCubeIds(ctNOTKILLED, [csSaber])) then
						points := -PIRATESHIP_POINTS[card]
				else
				begin
					if numberOfSkulls(Cubes, card) < MIN_SKULLS_FOR_LOST_MOVE then
					begin
						points := moveCombinationBonus(Cubes, card, moveMode, ctALLSAVED) + moveSideBonus(Cubes, card, moveMode,
							ctALLSAVED);

						points := points + PIRATESHIP_POINTS[card];
					end;

				end;
			end;
	end;
	moveCalculatePoints := points;
end;

end.

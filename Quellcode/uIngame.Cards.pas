{
  <summary>
  Diese unit stellt einen gemischten Cardstack zur Verfügung.
  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
}
unit uIngame.Cards;

interface

uses
  uBase;

type
  /// <summary>
  /// Definiert einen Kartenstapel von Spielkarten.
  /// </summary>
  TCardStack = array [TCardId] of TGameCard;

  /// <summary>
  /// Zeiger auf einen kartenStapel(für Test zwecke).
  /// </summary>
  PCardStack = ^TCardStack;

const
  /// <summary>
  /// Definiert den ubgemischten Kartenstapel.
  /// </summary>
  VANILLA_CARDSTACK: TCardStack = (gcAnimals, gcAnimals, gcAnimals, gcAnimals, gcDiamond, gcDiamond, gcDiamond, gcDiamond,
    gcGoldCoin, gcGoldCoin, gcGoldCoin, gcGoldCoin, gcGuardian, gcGuardian, gcGuardian, gcGuardian, gcPirate, gcPirate, gcPirate,
    gcPirate, gcTreasureIsland, gcTreasureIsland, gcTreasureIsland, gcTreasureIsland, gcSkull1, gcSkull1, gcSkull1, gcPirateShip2,
    gcPirateShip2, gcPirateShip3, gcPirateShip3, gcPirateShip4, gcPirateShip4, gcSkull2, gcSkull2);

  /// <summary>
  /// Ermittelt, basierend auf der gegebenen Karte und Würfelseite,
  /// ob und wie viele zusätzliche Würfel mit einberechnet werden müssen.
  /// </summary>
  /// <param name="card">Die zu prüfende Spielkarte.</param>
  /// <param name="cubeSide">Die gewürfelte Seite des Würfels.</param>
  /// <returns>
  /// Die Anzahl der zusätzlichen Würfel, die gewürfelt werden müssen.
  /// 0, wenn keine zusätzlichen Würfel gewürfelt werden müssen.
  /// </returns>
function additionalCubeSidesFrom(card: TGameCard; cubeSide: TCubeSide): TNumberOfCubes;

/// <summary>Mischt einen Kartenstapel.</summary>
/// <returns>Ein gemischter Kartenstapel vom Typ TCardStack.</returns>
function getShuffledCardStack: TCardStack;

implementation

function additionalCubeSidesFrom(card: TGameCard; cubeSide: TCubeSide): TNumberOfCubes;
begin
  additionalCubeSidesFrom := 0;
  if (ADD_CUBES_CARDS[card] > 0) and (cubeSide = ADD_CUBES_CARDS_SIDES[card]) then
    additionalCubeSidesFrom := ADD_CUBES_CARDS[card];

end;

function getShuffledCardStack: TCardStack;
var
  temp: TGameCard;
  I, firstIndex, secondIndex: integer;
  cardStack: TCardStack;
begin
  randomize;

  cardStack := VANILLA_CARDSTACK;
  for I := 1 to 1000 do
  begin
    firstIndex := random(NUMBER_OF_CARDS);
    secondIndex := random(NUMBER_OF_CARDS);

    temp := cardStack[firstIndex];
    cardStack[firstIndex] := cardStack[secondIndex];
    cardStack[secondIndex] := temp;
  end;
  getShuffledCardStack := cardStack;
end;

end.

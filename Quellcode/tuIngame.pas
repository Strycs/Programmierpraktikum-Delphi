{
  <summary>

  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
  <version>1.0</version>
  <remarks></remarks>
}
unit tuIngame;

interface

uses
  DUnitX.TestFramework, uIngame;

type

  [TestFixture]
  TIngameTests = class
  private
    ingame: TInGame;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    [Category('possibleActions')]
    procedure TestPossibleActions;

    [Test]
    [Category('possibleActions')]
    procedure TestInstaWin;

    [Test]
    [Category('possibleActions')]
    [TestCase('NoSkullCard', '0')]
    [TestCase('SkullCard1', '1')]
    [TestCase('SkullCard2', '2')]
    procedure TestSkullIslandMove(v0: integer);

    [Test]
    [Category('possibleActions')]
    [TestCase('NoSkullCard', '0')]
    [TestCase('Skull1 Card', '1')]
    [TestCase('Skull2 Card', '2')]
    procedure TestNotSkullIslandMove(v0: integer);

    [Test]
    [Category('nextMove')]
    procedure skullIslandUpdateScore;
  end;

implementation

uses
  ubase, uIngame.Cards, uIngame.Cubes, SysUtils;

const
   TEST_CARDSTACK: TCardStack = (gcAnimals, gcAnimals, gcAnimals, gcAnimals, gcDiamond, gcDiamond, gcDiamond, gcDiamond,
    gcGoldCoin, gcGoldCoin, gcGoldCoin, gcGoldCoin, gcGuardian, gcGuardian, gcGuardian, gcGuardian, gcPirate, gcPirate, gcPirate,
    gcPirate, gcTreasureIsland, gcTreasureIsland, gcTreasureIsland, gcTreasureIsland, gcSkull1, gcSkull1, gcSkull1, gcPirateShip2,
    gcPirateShip2, gcPirateShip3, gcPirateShip3, gcPirateShip4, gcPirateShip4, gcSkull2, gcSkull2);

  TEST_INSTAWIN_CARDSTACK: TCardStack = (gcGoldCoin, gcAnimals, gcAnimals, gcAnimals, gcDiamond, gcDiamond, gcDiamond, gcDiamond,
    gcAnimals, gcGoldCoin, gcGoldCoin, gcGoldCoin, gcGuardian, gcGuardian, gcGuardian, gcGuardian, gcPirate, gcPirate, gcPirate,
    gcPirate, gcTreasureIsland, gcTreasureIsland, gcTreasureIsland, gcTreasureIsland, gcSkull1, gcSkull1, gcSkull1, gcPirateShip2,
    gcPirateShip2, gcPirateShip3, gcPirateShip3, gcPirateShip4, gcPirateShip4, gcSkull2, gcSkull2);

  TEST_SKULLCARD: TCardStack = (gcSkull1, gcAnimals, gcAnimals, gcAnimals, gcDiamond, gcDiamond, gcDiamond, gcDiamond, gcGoldCoin,
    gcGoldCoin, gcGoldCoin, gcGoldCoin, gcGuardian, gcGuardian, gcGuardian, gcGuardian, gcPirate, gcPirate, gcPirate, gcPirate,
    gcTreasureIsland, gcTreasureIsland, gcTreasureIsland, gcTreasureIsland, gcAnimals, gcSkull1, gcSkull1, gcPirateShip2,
    gcPirateShip2, gcPirateShip3, gcPirateShip3, gcPirateShip4, gcPirateShip4, gcSkull2, gcSkull2);

  TEST_CUBES_CLASSIC_THROW: TCubeSideArray = (csDiamond, csDiamond, csDiamond, csMonkey, csMonkey, csSaber, csSaber, csSkull);

  TEST_CUBES_ALL_GOLD: TCubeSideArray = (csGoldCoin, csGoldCoin, csGoldCoin, csGoldCoin, csGoldCoin, csGoldCoin, csGoldCoin,
    csGoldCoin);

  TEST_SKULLISLAND: TCubeSideArray = (csSkull, csSkull, csSkull, csSkull, csGoldCoin, csGoldCoin, csGoldCoin, csGoldCoin);

  TEST_PLAYERNAMES: TPlayerNames = ('palyer1', 'payer2', '', '');
  TEST_FULL_PLAYERNAMES: TPlayerNames = ('palyer1', 'payer2', 'player3', 'player4');

procedure TIngameTests.TestPossibleActions;
var
  expectedActions, actions: TActions;
  cubeSides: TCubeSideArray;
begin
  ingame.start(TEST_PLAYERNAMES, 2, @TEST_CARDSTACK);
  actions := ingame.getPossibleActions;
  cubeSides := TEST_CUBES_CLASSIC_THROW;

  ingame.throwCubes(@cubeSides);

  actions := ingame.getPossibleActions;

  expectedActions := [gaWaitForGame,gaSaveCube,gaEndMove, gaThrow, gaStartGame, gaLoadGame];
  // Assert.IsTrue(expectedActions = actions);
  assert.AreEqual<TActions>(expectedActions, actions)
end;

procedure TIngameTests.TestSkullIslandMove(v0: integer);
var
  expectedActions, actions: TActions;
  cubeIdSides: TCubeIdSides;
  cardStack: TCardStack;
begin
  cubeIdSides.sides := TEST_SKULLISLAND;


  cardStack := TEST_CARDSTACK;
  case v0 of
    1:
      begin

        cubeIdSides.sides[3] := csGoldCoin;
        cardStack[0] := gcSkull1;
      end;
    2:
      begin
        cubeIdSides.sides[2] := csGoldCoin;
        cubeIdSides.sides[3] := csGoldCoin;
        cardStack[0] := gcSkull2;
      end;
  end;
  ingame.start(TEST_PLAYERNAMES, 2, @cardStack);

    cubeIdSides.ids:=ingame.getCubeIds([ctFree]);

  ingame.throwCubes(@cubeIdSides);
  actions := ingame.getPossibleActions;

  // Assert.IsTrue(ingame.getMoveMode = mmSkullIsland, 'moveMode wechsel in skllIslad fehlgeschlagen');
  assert.AreEqual<TMoveMode>(mmSkullIsland, ingame.getMoveMode, 'moveMode wechsel in skllIslad fehlgeschlagen');

  expectedActions := [gaWaitForGame,gaThrow, gaStartGame, gaLoadGame];
  // Assert.IsTrue(expectedActions = actions, 'falsche possibleActions');
  assert.AreEqual<TActions>(expectedActions, actions, 'falsche possibleActions');
  // move endet erst wenn kein skull gewürfelt wird

  cubeIdSides.sides[4] := csSkull;

  ingame.throwCubes(@cubeIdSides);
  actions := ingame.getPossibleActions;
  // Assert.IsTrue(expectedActions = actions, 'wuerfeln mit einem extra skull ist fehlgeschlagen');
  assert.AreEqual<TActions>(expectedActions, actions, 'wuerfeln mit einem extra skull ist fehlgeschlagen');

  ingame.throwCubes(@cubeIdSides);
  actions := ingame.getPossibleActions;
  expectedActions := [gaWaitForGame,gaThrow, gaStartGame, gaLoadGame];
  // Assert.IsTrue(expectedActions = actions, 'evaluiren fehlgeschlagen');
  assert.AreEqual<TActions>(expectedActions, actions, 'evaluiren fehlgeschlagen');
end;

procedure TIngameTests.Setup;
begin
  ingame := TInGame.create;
end;

procedure TIngameTests.skullIslandUpdateScore;
var
  playerId, id: TPlayerId;
  cubeIdSides:TCubeIdSides;
begin
  ingame.start(TEST_FULL_PLAYERNAMES, 4, @TEST_CARDSTACK);

  playerId := ingame.getCurrentPlayerId;

  cubeIdSides.ids:=ingame.getCubeIds([ctFree]);
  cubeIdSides.sides:=TEST_SKULLISLAND;

  ingame.throwCubes(@cubeIdSides);

  cubeIdSides.ids:=ingame.getCubeIds([ctFree]);

  ingame.throwCubes(@cubeIdSides); // same throw to end skullIsland Move

  ingame.endMove;

  for id := 0 to High(TPlayerId) do
    if id <> playerId then
      assert.AreEqual(-400, ingame.getPlayerStats(id).Points, format('calculation failed for id:%d', [id]));
end;

procedure TIngameTests.TearDown;
begin
  FreeAndNil(ingame)
end;

procedure TIngameTests.TestInstaWin;
var
  expectedActions, actions: TActions;
  cubeIdSides: TCubeIdSides;
begin
  ingame.start(TEST_PLAYERNAMES, 2, @TEST_INSTAWIN_CARDSTACK);

  cubeIdSides.sides := TEST_CUBES_ALL_GOLD;
  cubeIdSides.ids:=ingame.getCubeIds([ctFree]);
  ingame.throwCubes(@cubeIdSides);

  actions := ingame.getPossibleActions;

  expectedActions := [gaWaitForGame,gaStartGame, gaLoadGame];
  // Assert.IsTrue(expectedActions = actions);
  assert.AreEqual<TActions>(expectedActions, actions);

  // Assert.IsTrue(ingame.getGameStatus = gsFinished);
  assert.AreEqual<TGameStatus>(gsFinished, ingame.getGameStatus);
  // wenn 9er combo erreicht muss noch gesiichert werden?
end;

procedure TIngameTests.TestNotSkullIslandMove(v0: integer);
var
  cardStack: TCardStack;
begin
  cardStack := TEST_CARDSTACK;
  cardStack[0] := TPirateShipGameCard(ord(low(TPirateShipGameCard)) + v0);

  ingame.start(TEST_PLAYERNAMES, 2, @cardStack);

  ingame.throwCubes(@TEST_SKULLISLAND);

  // Assert.IsTrue(ingame.getMoveMode = mmPirateShip, 'moveMode ist mmPirateShip');
  assert.AreEqual<TMoveMode>(mmPirateShip, ingame.getMoveMode, 'moveMode ist mmPirateShip');
end;

initialization

TDUnitX.RegisterTestFixture(TIngameTests);

end.

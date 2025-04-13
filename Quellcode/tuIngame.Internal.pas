{
  <summary>

  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
  <version>1.0</version>
  <remarks></remarks>
}
unit tuIngame.Internal;

interface

uses
	DUnitX.TestFramework;

type

	[TestFixture]
	TTest_IngameIntenal = class
	public

		[Test]
		[TestCase('mmNormal: 3*csDiamond',
			'csDiamond,csDiamond,csDiamond,csParrot,csParrot,csSaber,csSaber,csSkull,gcAnimals,mmNormal,400')]
		[TestCase('mmNormal: 3*csDiamond + gcDiamond',
			'csDiamond,csDiamond,csDiamond,csParrot,csParrot,csSaber,csSaber,csSkull,gcDiamond,mmNormal,600')]
		[TestCase('mmNormal: 4*Monkeys +3*parrot + gcAnimals',
			'csSkull,csMonkey,csMonkey,csMonkey,csMonkey,csParrot,csParrot,csParrot,gcAnimals,mmNormal,2000')]
		[TestCase('mmNormal: 3*csGoldCoin + gcPirate',
			'csGoldCoin,csGoldCoin,csGoldCoin,csParrot,csParrot,csSaber,csSaber,csSkull,gcPirate,mmNormal,800')]
		[TestCase('mmSkullIsland: 5*skulls',
			'csSkull,csSkull,csSkull,csSkull,csSkull,csSaber,csSaber,csSaber,gcAnimals,mmSkullIsland,-500')]
		[TestCase('mmSkullIsland: 5*skulls + gcPirate',
			'csSkull,csSkull,csSkull,csSkull,csSkull,csSaber,csSaber,csSaber,gcPirate,mmSkullIsland,-1000')]
		[TestCase('mmSkullIsland: 8*skulls + gcSkull2',
			'csSkull,csSkull,csSkull,csSkull,csSkull,csSkull,csSkull,csSkull,gcSkull2,mmSkullIsland,-1000')]
		[TestCase('treasureChest: 5*saber +3*parrot + gcGuardian',
			'csSaber,csSaber,csSaber,csSaber,csSaber,csParrot,csParrot,csParrot,gcGuardian,mmNormal,1100')]
		[TestCase('treasureChest: 5*Monkeys +3*parrot + gcAnimals',
			'csMonkey,csMonkey,csMonkey,csMonkey,csMonkey,csParrot,csParrot,csParrot,gcAnimals,mmNormal,4500')]

		procedure MoveCalculatePoints(v0, v1, v2, v3, v4, v5, v6, v7, cardId, moveModeIndex: string; expected: integer);
	end;

implementation

uses
	uBase, uIngame.Cubes, uIngame, uIngame.Internal, SysUtils, Types, TypInfo;

function cubeSide(str: string): TCubeSide;
var
	value: integer;
begin
	value := GetEnumValue(TypeInfo(TCubeSide), str);
	if value <> -1 then cubeSide := TCubeSide(value)
	else assert.Fail('parameter ' + str + ' nicht vom type TCubeSide');

end;

function gameCard(str: string): TGameCard;
var
	value: integer;
begin
	value := GetEnumValue(TypeInfo(TGameCard), str);
	if value <> -1 then gameCard := TGameCard(value)
	else assert.Fail('parameter ' + str + ' nicht vom type TGameCard');

end;

function moveMode(str: string): TMoveMode;
var
	value: integer;
begin
	value := GetEnumValue(TypeInfo(TMoveMode), str);
	if value <> -1 then moveMode := TMoveMode(value)
	else assert.Fail('parameter ' + str + ' nicht vom type TMoveMode');

end;

function cubeSideArray(v0, v1, v2, v3, v4, v5, v6, v7: string): TCubeSideArray;
begin
	cubeSideArray[0] := cubeSide(v0);
	cubeSideArray[1] := cubeSide(v1);
	cubeSideArray[2] := cubeSide(v2);
	cubeSideArray[3] := cubeSide(v3);
	cubeSideArray[4] := cubeSide(v4);
	cubeSideArray[5] := cubeSide(v5);
	cubeSideArray[6] := cubeSide(v6);
	cubeSideArray[7] := cubeSide(v7);
end;

procedure TTest_IngameIntenal.MoveCalculatePoints(v0, v1, v2, v3, v4, v5, v6, v7, cardId, moveModeIndex: string;
	expected: integer);
var
	cubes: TGameCubes;
	id: TCubeId;
	points: integer;
	idSides: TCubeIdSides;
	mMode: TMoveMode;
	card: TGameCard;
begin
	cubes := TGameCubes.create;

	idSides.ids := ALL_CUBE_IDS;
	idSides.sides := cubeSideArray(v0, v1, v2, v3, v4, v5, v6, v7);
	cubes.throwCubes(idSides);

	for id in cubes.getCubeIds([ctFree]) do cubes.setCubeState(id, ctSaved);
	card := gameCard(cardId);
	mMode := moveMode(moveModeIndex);
	points := uingame.internal.moveCalculatePoints(cubes, card, mMode);

	assert.AreEqual(expected, points);
end;

initialization

TDUnitX.RegisterTestFixture(TTest_IngameIntenal);

end.

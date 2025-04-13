unit uPrint;

interface

uses
  TypInfo,
  uBase,
  uCubes;

procedure printStats(player: TPlayerStat);
procedure printAllStats(allStats: TAllStats);
procedure printCards(theCards: TCardStack);
procedure printCubes(theCubes: TGameCubes);

implementation

// in player record/no out/print stats from spezific Player
procedure printStats(player: TPlayerStat);
begin
  with player do
  begin
    writeln(name + ' ', Points);
  end;
end;

// in allStatas array/no out/ print all players stats in console
procedure printAllStats(allStats: TAllStats);
begin
  for var index := Low(allStats) to High(allStats) do
    printStats(allStats[index])
end;

// no theCards array/no out/Print all cards
procedure printCards(theCards: TCardStack);
var
  cardStr: string;
begin
  for var index := Low(theCards) to High(theCards) do
  begin
    cardStr := GetEnumName(TypeInfo(TGameCards), ord(theCards[index]));
    writeln(cardStr);
  end;
end;

procedure printCubes(theCubes: TGameCubes);
var
  sideStr: string;
begin
  for var index := Low(theCubes) to High(theCubes) do
  begin
    sideStr := GetEnumName(TypeInfo(TCubeSides), ord(theCubes[index].side));
    delete(sideStr, 1, 2);

    writeln(index, ' ' + sideStr + ' saved: ', theCubes[index].saved, ' throwable: ', theCubes[index].throwable);
  end;

end;

end.

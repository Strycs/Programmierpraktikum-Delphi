{
  <summary>

  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
  <version>1.0</version>
  <remarks></remarks>
}
unit tFmGame.utils;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TFmGameUtilsTests = class
  public
    // Sample Methods
    // Simple single Test
    [Test]
    [TestCase('TestIndex 0', '0,25,25')]
    [TestCase('TestIndex 2', '2,25,125')]
    [TestCase('TestIndex 3', '3,125,125')]
    [TestCase('TestIndex 5', '5,125,225')]
    [TestCase('TestIndex 7', '7,125,325')]
    procedure TestCubeGridCells(index, X, Y: Integer);
  end;

implementation

uses
  types, SysUtils, fmGame.utils;

procedure TFmGameUtilsTests.TestCubeGridCells(index, X, Y: Integer);
var
  colums: Integer;
  gridRect: TRect;
  p0, p1: TPoint;
begin
  colums := 2;
  gridRect := TRect.Create(0, 0, 200, 400);

  p0 := Point(X, Y);
  p1 := getCubeGridPos(index, colums, gridRect);

  if p0 <> p1 then
    assert.FailFmt('expected [%d,%d] but found [%d,%d], index[%d]', [p0.X, p0.Y, p1.X, p1.Y, index]);

  assert.IsTrue(True);//this is a hack to avoid TestInsight warnings
end;

initialization

TDUnitX.RegisterTestFixture(TFmGameUtilsTests);

end.

{
  <summary>

  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
  <version>1.0</version>
  <remarks></remarks>
}
unit tuInGame.Cubes;

interface

uses
  DUnitX.TestFramework, uIngame.Cubes;

type

  [TestFixture]
  TGameCubeTests = class
  private
		cubes: TGameCubes;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
  end;

implementation

uses
  uBase;

procedure TGameCubeTests.Setup;
begin
	cubes := TGameCubes.create;
end;

procedure TGameCubeTests.TearDown;
begin
  cubes.Free;
end;

initialization

TDUnitX.RegisterTestFixture(TGameCubeTests);

end.

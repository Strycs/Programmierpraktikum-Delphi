{
  <summary>
  Diese Unit ist für das Managen der Würfel zuständig.
  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
}
unit uInGame.Cubes;

interface

uses
  uBase;

type
  /// <summary>
  /// Repräsentiert einen einzelnen Spielwürfel mit Seite und Zustand.
  /// </summary>
  TGameCube = record
    side: TCubeSide;
    state: TCubeState;
  end;

  /// <summary>
  /// Ein Array type von Spielwürfeln, indiziert durch TCubeId.
  /// </summary>
  TGameCubesArray = array [TCubeId] of TGameCube;

  /// <summary>
  /// Klasse zur Verwaltung der Spielwürfel.
  /// </summary>
  TGameCubes = class(TObject)
  private
    /// <summary>Das Array, das die Würfel speichert.</summary>
    theCubes: TGameCubesArray;

    /// <summary>
    /// Wirft einen einzelnen Würfel.
    /// </summary>
    /// <param name="id">Die ID des zu werfenden Würfels.</param>
    procedure throwCube(id: integer);
  public
    /// <summary>
    /// Wird nach dem create aufgerufen und nutzt initCubes zum inizialisiert die Würfel.
    /// </summary>
    procedure afterConstruction; override;

    /// <summary>
    /// Initialisiert die Würfel im Array. Setzt alle Würfelseiten auf den niedrigsten Wert und den Status auf ctFree.
    /// </summary>
    procedure initCubes;

    /// <summary>
    /// Wirft alle freien Würfel.
    /// </summary>
    procedure throwCubes(throwables: TCubeIds); overload;

    /// <summary>
    /// Wirft Würfel mit vorgegebenen Seiten,ist gedacht für den cheat Modus.
    /// </summary>
    /// <param name="idSides">Record, der Würfel-IDs und zugehörige Seiten enthält.</param>
    procedure throwCubes(idSides: TCubeIdSides); overload;

    /// <summary>
    /// Gibt die IDs der Würfel zurück, die den angegebenen Zuständen und optional Seiten entsprechen.
    /// </summary>
    /// <param name="states">Die Menge der zu filternden Würfelzustände.</param>
    /// <param name="sides">Die Menge der zu filternden Würfelseiten. Standardmäßig alle Seiten (csALL).</param>
    /// <returns>Eine Menge von Würfel-IDs.</returns>
    function getCubeIds(states: TCubeStates; sides: TCubeSides = csALL): TCubeIds;

    /// <summary>
    /// Gibt die Seite eines Würfels mit der angegebenen ID zurück.
    /// </summary>
    /// <param name="id">Die ID des Würfels.</param>
    /// <returns>Die Seite des Würfels.</returns>
    function getCubeSide(id: TCubeId): TCubeSide;

    /// <summary>
    /// Gibt den Zustand eines Würfels mit der angegebenen ID zurück.
    /// </summary>
    /// <param name="id">Die ID des Würfels.</param>
    /// <returns>Der Zustand des Würfels.</returns>
    function getCubeState(id: TCubeId): TCubeState;

    /// <summary>
    /// Setzt den Zustand eines Würfels mit der angegebenen ID.
    /// </summary>
    /// <param name="id">Die ID des Würfels.</param>
    /// <param name="state">Der neue Zustand des Würfels.</param>
    procedure setCubeState(id: TCubeId; state: TCubeState);

    destructor destroy; override;
  end;

  /// <summary>
  /// Zählt die Anzahl der Würfel in einer Menge.
  /// </summary>
  /// <param name="cubeIds">Die Menge der Würfel-IDs.</param>
  /// <returns>Die Anzahl der Würfel.</returns>
function numberOf(cubeIds: TCubeIds): TNumberOfCubes;

implementation

function numberOf(cubeIds: TCubeIds): TNumberOfCubes;
var
  rslt: TNumberOfCubes;
  id: TCubeId;
begin
  rslt := 0;
  for id in cubeIds do
    inc(rslt);
  numberOf := rslt;
end;

{ cubes }
procedure TGameCubes.afterConstruction;
begin
  inherited; // Calls TObject.AfterConstruction (does nothing by default)
  initCubes
end;

procedure TGameCubes.initCubes;
var
  id: integer;
begin
  for id := Low(theCubes) to High(theCubes) do
    with theCubes[id] do
    begin
      side := Low(TCubeSide);
      state := ctFree;
    end;

end;

procedure TGameCubes.setCubeState(id: TCubeId; state: TCubeState);
begin
  theCubes[id].state := state;
end;

procedure TGameCubes.throwCube(id: integer);
var
  randomIndex: integer;
begin
  randomIndex := random(6);
  with theCubes[id] do
  begin
    side := TCubeSide(randomIndex);

    if side <> csSkull then
      state := ctFree
    else
      state := ctKilled;
  end;

end;

procedure TGameCubes.throwCubes(idSides: TCubeIdSides);
var
  id: TCubeId;
begin
  with idSides do
  begin
    for id in ids do
      with theCubes[id] do
      begin
        side := sides[id];
        if side <> csSkull then
          state := ctFree
        else
          state := ctKilled;
      end;
  end;
end;

procedure TGameCubes.throwCubes(throwables: TCubeIds);
var
  id: integer;
begin
  for id in throwables do
    throwCube(id);
end;

destructor TGameCubes.destroy;
begin
  inherited;
end;

function TGameCubes.getCubeIds(states: TCubeStates; sides: TCubeSides): TCubeIds;
var
  idSet: TCubeIds;
  id: TCubeId;
begin
  idSet := [];
  for id := Low(theCubes) to High(theCubes) do
    if (theCubes[id].side in sides) and (theCubes[id].state in states) then
      include(idSet, id);
  getCubeIds := idSet;
end;

function TGameCubes.getCubeSide(id: TCubeId): TCubeSide;
begin
  getCubeSide := self.theCubes[id].side;
end;

function TGameCubes.getCubeState(id: TCubeId): TCubeState;
begin
  getCubeState := self.theCubes[id].state;
end;

end.

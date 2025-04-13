{
  <summary>
  Diese Unit ist f�r das Managen der W�rfel zust�ndig.
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
  /// Repr�sentiert einen einzelnen Spielw�rfel mit Seite und Zustand.
  /// </summary>
  TGameCube = record
    side: TCubeSide;
    state: TCubeState;
  end;

  /// <summary>
  /// Ein Array type von Spielw�rfeln, indiziert durch TCubeId.
  /// </summary>
  TGameCubesArray = array [TCubeId] of TGameCube;

  /// <summary>
  /// Klasse zur Verwaltung der Spielw�rfel.
  /// </summary>
  TGameCubes = class(TObject)
  private
    /// <summary>Das Array, das die W�rfel speichert.</summary>
    theCubes: TGameCubesArray;

    /// <summary>
    /// Wirft einen einzelnen W�rfel.
    /// </summary>
    /// <param name="id">Die ID des zu werfenden W�rfels.</param>
    procedure throwCube(id: integer);
  public
    /// <summary>
    /// Wird nach dem create aufgerufen und nutzt initCubes zum inizialisiert die W�rfel.
    /// </summary>
    procedure afterConstruction; override;

    /// <summary>
    /// Initialisiert die W�rfel im Array. Setzt alle W�rfelseiten auf den niedrigsten Wert und den Status auf ctFree.
    /// </summary>
    procedure initCubes;

    /// <summary>
    /// Wirft alle freien W�rfel.
    /// </summary>
    procedure throwCubes(throwables: TCubeIds); overload;

    /// <summary>
    /// Wirft W�rfel mit vorgegebenen Seiten,ist gedacht f�r den cheat Modus.
    /// </summary>
    /// <param name="idSides">Record, der W�rfel-IDs und zugeh�rige Seiten enth�lt.</param>
    procedure throwCubes(idSides: TCubeIdSides); overload;

    /// <summary>
    /// Gibt die IDs der W�rfel zur�ck, die den angegebenen Zust�nden und optional Seiten entsprechen.
    /// </summary>
    /// <param name="states">Die Menge der zu filternden W�rfelzust�nde.</param>
    /// <param name="sides">Die Menge der zu filternden W�rfelseiten. Standardm��ig alle Seiten (csALL).</param>
    /// <returns>Eine Menge von W�rfel-IDs.</returns>
    function getCubeIds(states: TCubeStates; sides: TCubeSides = csALL): TCubeIds;

    /// <summary>
    /// Gibt die Seite eines W�rfels mit der angegebenen ID zur�ck.
    /// </summary>
    /// <param name="id">Die ID des W�rfels.</param>
    /// <returns>Die Seite des W�rfels.</returns>
    function getCubeSide(id: TCubeId): TCubeSide;

    /// <summary>
    /// Gibt den Zustand eines W�rfels mit der angegebenen ID zur�ck.
    /// </summary>
    /// <param name="id">Die ID des W�rfels.</param>
    /// <returns>Der Zustand des W�rfels.</returns>
    function getCubeState(id: TCubeId): TCubeState;

    /// <summary>
    /// Setzt den Zustand eines W�rfels mit der angegebenen ID.
    /// </summary>
    /// <param name="id">Die ID des W�rfels.</param>
    /// <param name="state">Der neue Zustand des W�rfels.</param>
    procedure setCubeState(id: TCubeId; state: TCubeState);

    destructor destroy; override;
  end;

  /// <summary>
  /// Z�hlt die Anzahl der W�rfel in einer Menge.
  /// </summary>
  /// <param name="cubeIds">Die Menge der W�rfel-IDs.</param>
  /// <returns>Die Anzahl der W�rfel.</returns>
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

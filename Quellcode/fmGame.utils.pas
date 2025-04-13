{
  <summary>
  Diese Unit lagert Funktionen für das platzieren und anzeigen der Würfel aus.
  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
}
unit fmGame.utils;

interface

uses
  uBase,
  types,
  Vcl.ExtCtrls;

type
  /// <summary>
  /// Record zur Speicherung von Würfelpositionen.
  /// </summary>
  TPlacements = record
    /// <summary>Menge der Würfel-IDs.</summary>
    cubeIds: TCubeIds;
    /// <summary>Array von Rechtecken für die Positionen der Würfel.</summary>
    rects: array [TCubeId] of TRect;
  end;

const
  /// <summary>Größe eines Würfels.</summary>
  CUBE_SIZE = 50;
  /// <summary>Anzahl der Spalten im Würfelraster.</summary>
  COLUMS = 2;

  /// <summary>
  /// Berechnet die Position eines Würfels im Raster.
  /// </summary>
  /// <param name="index">Der Index des Würfels im Array.</param>
  /// <param name="COLUMS">Die Anzahl der Spalten im Raster.</param>
  /// <param name="gridRect">Das Rechteck, das den verfügbaren Platz für das Raster definiert.</param>
  /// <returns>Die berechnete Position (TPoint) des Würfels.</returns>
function getCubeGridPos(index, COLUMS: integer; gridRect: TRect): TPoint;

/// <summary>
/// Generiert eine zufällige Position für einen einzelnen Würfel.
/// </summary>
/// <param name="rectSize">Die Größe des Bereichs, in dem der Würfel platziert werden kann.</param>
/// <returns>Die zufällige Position (TPoint) des Würfels.</returns>
function singleCubeRandom(rectSize: TPoint): TPoint;

/// <summary>
/// Erzeugt neue zufällige Platzierungen für eine Menge von Würfeln.
/// </summary>
/// <param name="newCubeIds">Die Menge der Würfel-IDs, für die Platzierungen erzeugt werden sollen.</param>
/// <param name="placements">Die TPlacements-Variable, in der die Platzierungen gespeichert werden.</param>
/// <param name="rectSize">Die Größe des Bereichs in dem die Würfel platziert werden können.</param>
procedure newRandomPlacements(newCubeIds: TCubeIds; var placements: TPlacements; rectSize: TPoint);

/// <summary>
/// Prüft, ob ein gegebenes Rechteck mit einem der Rechtecke in den vorhandenen Platzierungen kollidiert.
/// </summary>
/// <param name="rect">Das zu prüfende Rechteck.</param>
/// <param name="placements">Die vorhandenen Platzierungen.</param>
/// <returns>True, wenn eine Kollision vorliegt, sonst False.</returns>
function isCollision(rect: TRect; const placements: TPlacements): boolean;

/// <summary>
/// Zeigt oder verbirgt alle Steuerelemente in einem Panel.
/// </summary>
/// <param name="panel">Das Panel, dessen Steuerelemente ein- oder ausgeblendet werden sollen.</param>
/// <param name="visible">True, um die Steuerelemente anzuzeigen, False, um sie zu verbergen.</param>
procedure showControls(panel: TPanel; visible: boolean);

implementation

uses math;

function getCubeGridPos(index, COLUMS: integer; gridRect: TRect): TPoint;
var
  row, col: integer;
  gridSize, cellSize, offset: TPoint;
begin
  gridSize := gridRect.BottomRight - gridRect.TopLeft;

  cellSize.X := math.max(gridSize.X div COLUMS, CUBE_SIZE);
  cellSize.Y := math.max(gridSize.Y div (NUMBER_OF_CUBES div COLUMS), CUBE_SIZE);

  row := index div COLUMS;
  col := index mod COLUMS;

  offset := point((cellSize.X - CUBE_SIZE) div 2, (cellSize.Y - CUBE_SIZE) div 2);

  getCubeGridPos := gridRect.TopLeft + point(col * cellSize.Y, row * cellSize.X) + offset;

end;

function isCollision(rect: TRect; const placements: TPlacements): boolean;
var
  collied: boolean;
  id: TCubeId;
begin
  collied := false;
  for id in placements.cubeIds do
    if not collied then
      collied := placements.rects[id].IntersectsWith(rect);

  isCollision := collied;
end;

procedure newRandomPlacements(newCubeIds: TCubeIds; var placements: TPlacements; rectSize: TPoint);
var
  newId: TCubeId;
  rect: TRect;

begin
  for newId in newCubeIds do
  begin
    rect := placements.rects[newId];

    repeat
      rect.location := singleCubeRandom(rectSize);
    until not isCollision(rect, placements);

    Include(placements.cubeIds, newId);
    placements.rects[newId] := rect;

  end;
end;

function singleCubeRandom(rectSize: TPoint): TPoint;
var
  cubeDiagonal: integer;
begin
  cubeDiagonal := round(sqrt(sqr(CUBE_SIZE) + sqr(CUBE_SIZE)));
  singleCubeRandom.X := random(rectSize.X - cubeDiagonal);
  singleCubeRandom.Y := random(rectSize.Y - cubeDiagonal);
end;

procedure showControls(panel: TPanel; visible: boolean);
var
  id: integer;
begin
  for id := 0 to panel.ControlCount - 1 do
    panel.Controls[id].visible := visible;
end;

end.

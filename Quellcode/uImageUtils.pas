{
	<summary>
	Diese Unit stelle eine image-Rotate-Funktion (RotateBitmapInPlace) zur Verfügung
  </summary>
  <author>Jörg Schobert</author>
  <created>1.10.2024</created>
}
unit uImageUtils;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.ExtCtrls;

/// <summary>
/// Rotiert ein Bitmap um einen gegebenen Winkel und passt optional die Bildgröße an.
/// Die Rotation erfolgt "in place", d.h. das Zielbild wird verändert.
/// </summary>
/// <param name="igDest">Das Ziel-TImage, in das das rotierte Bild gezeichnet wird.</param>
/// <param name="igSource">Das Quell-TImage, dessen Picture rotiert werden soll.</param>
/// <param name="Angle">Der Rotationswinkel in Grad.  Positive Werte drehen im Uhrzeigersinn, negative gegen den Uhrzeigersinn.</param>
/// <param name="adjustImage">Optionaler Parameter. Wenn true, wird die Größe von igDest an die Größe des rotierten Bildes angepasst. Standardmäßig true.</param>
procedure RotateBitmapInPlace(igDest, igSource: TImage; Angle: single; adjustImage: boolean = true);

implementation

uses types, math, math.Vectors;

const
	/// <summary>Konstante zur Umrechnung von Grad in Bogenmaß.</summary>
	RAD = 180 / PI;

	/// <summary>
	/// Berechnet die neue Größe eines Bildes nach einer Rotation.
	/// </summary>
	/// <param name="width">Die ursprüngliche Breite des Bildes.</param>
	/// <param name="height">Die ursprüngliche Höhe des Bildes.</param>
	/// <param name="r">Der Rotationswinkel im Bogenmaß.</param>
	/// <returns>Ein TPoint, der die neue Breite und Höhe des rotierten Bildes enthält.</returns>
function calcNewSize(const width, height: integer; r: single): Tpoint;
var
	rotMatrix: TMatrix;
	p1, p2, p3, p4: TPointF; // oben links, oben rechts, unten links, unten rechts
	maxX, maxY, minX, minY: single;

begin
	rotMatrix := TMatrix.CreateRotation(r);
	// Eckpunkte erstellen
	p1 := Point(0, 0);
	p2 := Point(width, 0);
	p3 := Point(width, height);
	p4 := Point(0, height);

	p1 := p1 * rotMatrix;
	p2 := p2 * rotMatrix;
	p3 := p3 * rotMatrix;
	p4 := p4 * rotMatrix;

	// Ausmaße des Zielbildes bestimmen
	maxX := max(max(max(p1.x, p2.x), p3.x), p4.x);
	maxY := max(max(max(p1.y, p2.y), p3.y), p4.y);
	minX := min(min(min(p1.x, p2.x), p3.x), p4.x);
	minY := min(min(min(p1.y, p2.y), p3.y), p4.y);

	calcNewSize.x := ceil(maxX - minX);
	calcNewSize.y := ceil(maxY - minY);

end;

procedure RotateBitmapInPlace(igDest, igSource: TImage; Angle: single; adjustImage: boolean);
var
	bmpSource, bmpTemp: TBitmap;
	oldMode: integer;
	retBool: longBool;
	xfRotate, xfTranslate: TXFORM;
	Radians: single;
	oldCenter, newCenter, newSize: Tpoint;
	lenDiagonal: integer;

begin
	Radians := Angle * RAD;

	if adjustImage then
	begin
		newSize := calcNewSize(igSource.width, igSource.height, Radians);
		igDest.width := newSize.x;
		igDest.height := newSize.y;
	end;

	bmpSource := TBitmap.Create;
	bmpTemp := TBitmap.Create;
	try
		bmpSource.Assign(igSource.Picture.Graphic);

		bmpTemp.canvas.brush.Style := bsClear;

		newSize := calcNewSize(bmpSource.width, bmpSource.height, Radians);
		{
      there is an issue if the newSize is not big ennough to hold the orignal bitmap.
      as the bitBlt seems to copy the bitmap first and then apply the worldTransformation
      therefore if the newSize is already applies to the bmpTemp and newSize is "smaller in some dimension then
      the original bitmap, the original bitmap is cropped.
      therefore
      1st create a bitmap which is big ennough to handle the oldBitmap and also the rotated bitmap.
      2nd rotate the bitmap around the center! and move it to the center of the bitmap
      3nd move the bitmap to the upper left corner
      4nd set newSize of bitmap
    }

    // 1.

    lenDiagonal := ceil(sqrt(sqr(bmpSource.width) + sqr(bmpSource.height)));
    bmpTemp.SetSize(lenDiagonal, lenDiagonal);

    // this is the magic graphicsmode to allow transformation of bitmaps
    oldMode := SetGraphicsMode(bmpTemp.canvas.Handle, GM_ADVANCED);

    // 2.
    xfRotate.eM11 := Cos(Radians);
    xfRotate.eM12 := Sin(Radians);
    xfRotate.eM21 := -Sin(Radians);
    xfRotate.eM22 := Cos(Radians);
    xfRotate.eDx := 0;
    xfRotate.eDy := 0;

    newCenter := Point(bmpTemp.width div 2, bmpTemp.height div 2);
    oldCenter := Point(bmpSource.width div 2, bmpSource.height div 2);

    xfRotate.eDx := newCenter.x - (oldCenter.x * xfRotate.eM11 + oldCenter.y * xfRotate.eM21);
    xfRotate.eDy := newCenter.y - (oldCenter.x * xfRotate.eM12 + oldCenter.y * xfRotate.eM22);

    retBool := SetWorldTransform(bmpTemp.canvas.Handle, xfRotate);

    // 3.
    xfTranslate.eM11 := 1;
    xfTranslate.eM12 := 0;
    xfTranslate.eM21 := 0;
    xfTranslate.eM22 := 1;

    xfTranslate.eDx := -(lenDiagonal - newSize.x) div 2;
    xfTranslate.eDy := -(lenDiagonal - newSize.y) div 2;

    retBool := ModifyWorldTransform(bmpTemp.canvas.Handle, xfTranslate, MWT_RIGHTMULTIPLY);

    retBool := BitBlt(bmpTemp.canvas.Handle, 0, 0, bmpTemp.width, bmpTemp.height, bmpSource.canvas.Handle, 0, 0, SRCCOPY);

    // 4.
    bmpTemp.SetSize(newSize.x, newSize.y);

    igDest.Picture.Graphic := bmpTemp;

  finally
    bmpTemp.Free;
    bmpSource.Free;
  end;
end;

end.

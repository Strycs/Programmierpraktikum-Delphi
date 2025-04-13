{
  <summary>
  Die Unit ist f�r die GUI des Cheat-Throw da.
  </summary>
  <author>Morten Schobert</author>
  <created>18.03.2025</created>
  <version>1.0</version>
  <remarks></remarks>
}
unit fmCheatThrow;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
	uBase;

/// <summary>
/// TfrmCheatThrow stellt ein Formular dar, das es erm�glicht, die W�rfelseiten manuell (f�r Cheat-Zwecke) anzupassen.
/// </summary>
type
	TfrmCheatThrow = class(TForm)
		ComboBox1: TComboBox;
		ComboBox2: TComboBox;
		ComboBox3: TComboBox;
		ComboBox4: TComboBox;
		ComboBox5: TComboBox;
		ComboBox6: TComboBox;
		ComboBox7: TComboBox;
		ComboBox0: TComboBox;
		BitBtnOk: TBitBtn;
		BitBtnAbbrechen: TBitBtn;
	private
		{ Private declarations }
	public
		/// <summary>
		/// Setzt die W�rfelseiten in den ComboBoxen des Formulars.
		/// Durchl�uft alle ComboBoxen (entsprechend der W�rfel-IDs), aktiviert diese, wenn die jeweilige W�rfel-ID
		/// in der �bergebenen Menge enthalten ist, und setzt den ItemIndex gem�� der �bergebenen W�rfelseite.
		/// </summary>
		/// <param name="cubeSides">Ein Array vom Typ TCubeSIdeArray, das die zu setzenden W�rfelseiten enth�lt.</param>
		/// <param name="ids">Eine Menge von W�rfel-IDs, die aktiv sein sollen.</param>
		procedure setThrowables(cubeIdSides: TCubeIdSides);

		/// <summary>
		/// Liest die aktuellen W�rfelseiten aus den ComboBoxen des Formulars aus.
		/// Durchl�uft alle ComboBoxen (entsprechend der W�rfel-IDs) und weist den ItemIndex als W�rfelseite zu.
		/// </summary>
		/// <returns>Ein Array vom Typ TCubeSIdeArray, das die aktuellen W�rfelseiten enth�lt.</returns>
		function getCubeIdSides: TCubeIdSides;
	end;

implementation

{$R *.dfm}
{ TForm1 }

function TfrmCheatThrow.getCubeIdSides: TCubeIdSides;
var
	comboBox: TComboBox;
	ids: TCubeIds;
begin
	ids := [];
	getCubeIdSides.ids := [];
	for var id := Low(tCubeId) to High(tCubeId) do
	begin
		comboBox := FindComponent('ComboBox' + IntToStr(id)) as TComboBox;
		if comboBox.Enabled then
			Include(ids, id);
		getCubeIdSides.sides[id] := TCubeSide(comboBox.ItemIndex);
	end;
	getCubeIdSides.ids := ids;
end;

procedure TfrmCheatThrow.setThrowables(cubeIdSides: TCubeIdSides);
var
	comboBox: TComboBox;
begin
	for var id := Low(tCubeId) to High(tCubeId) do
	begin
		comboBox := FindComponent('ComboBox' + IntToStr(id)) as TComboBox;
		comboBox.Enabled := id in cubeIdSides.ids;
		comboBox.ItemIndex := ord(cubeIdSides.sides[id]);
	end;
end;

end.

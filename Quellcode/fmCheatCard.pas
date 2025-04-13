unit fmCheatCard;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
	uBase;

type
	TfrmCheatCard = class(TForm)
		BitBtnOk: TBitBtn;
		BitBtnAbbrechen: TBitBtn;
		cbGameCard: TComboBox;
	private
		{ Private declarations }
	public
		function getGameCard: TGameCard;
		procedure setGameCard(card: TGameCard);
	end;

var
	frmCheatCard: TfrmCheatCard;

implementation

{$R *.dfm}
{ TForm1 }

function TfrmCheatCard.getGameCard: TGameCard;
begin
	getGameCard := TGameCard(cbGameCard.ItemIndex);
end;

procedure TfrmCheatCard.setGameCard(card: TGameCard);
begin
	cbGameCard.ItemIndex := ord(card);
end;

end.

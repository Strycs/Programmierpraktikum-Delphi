program PiratenKarpern;

uses
  Vcl.Forms,
  uBase in 'uBase.pas',
  uInGame in 'uInGame.pas',
  uInGame.Cubes in 'uInGame.Cubes.pas',
  uLogging in 'uLogging.pas',
  uIngame.Cards in 'uIngame.Cards.pas',
  uInGame.Players in 'uInGame.Players.pas',
  fmGame.utils in 'fmGame.utils.pas',
  uImageUtils in 'uImageUtils.pas',
  UInGame.Internal in 'UInGame.Internal.pas',
  uIngame.IO in 'uIngame.IO.pas',
  fmGame in 'fmGame.pas' {frmGame},
  fmSelectPlayers in 'fmSelectPlayers.pas' {fmSelectPlayers},
  fmCheatThrow in 'fmCheatThrow.pas' {frmCheatThrow},
  uAction in 'uAction.pas',
  uMemCounter in 'uMemCounter.pas',
  uArchiv.Players in 'uArchiv.Players.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
	Application.CreateForm(TfrmGame, frmGame);
  application.Run;

end.

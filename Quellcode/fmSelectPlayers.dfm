object fmSelectPlayers: TfmSelectPlayers
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'w'#228'hle Player'
  ClientHeight = 389
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object lbAccessConditions: TLabel
    Left = 62
    Top = 278
    Width = 201
    Height = 22
    Alignment = taCenter
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object lbePlayer1: TLabeledEdit
    Left = 78
    Top = 49
    Width = 200
    Height = 29
    EditLabel.Width = 38
    EditLabel.Height = 29
    EditLabel.Caption = 'Player1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    LabelPosition = lpLeft
    LabelSpacing = 20
    MaxLength = 20
    ParentFont = False
    TabOrder = 0
    Text = 'Pirate1'
    OnChange = lbePlayerChange
  end
  object lbePlayer2: TLabeledEdit
    Left = 78
    Top = 107
    Width = 200
    Height = 29
    EditLabel.Width = 38
    EditLabel.Height = 29
    EditLabel.Caption = 'Player2'
    EditLabel.Transparent = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    LabelPosition = lpLeft
    LabelSpacing = 20
    MaxLength = 20
    ParentFont = False
    TabOrder = 1
    Text = 'Pirate2'
    OnChange = lbePlayerChange
  end
  object lbePlayer3: TLabeledEdit
    Left = 78
    Top = 166
    Width = 200
    Height = 29
    EditLabel.Width = 38
    EditLabel.Height = 29
    EditLabel.Caption = 'Player3'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    LabelPosition = lpLeft
    LabelSpacing = 20
    MaxLength = 20
    ParentFont = False
    TabOrder = 2
    Text = ''
    OnChange = lbePlayerChange
  end
  object lbePlayer4: TLabeledEdit
    Left = 78
    Top = 225
    Width = 200
    Height = 29
    EditLabel.Width = 38
    EditLabel.Height = 29
    EditLabel.Caption = 'Player4'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    LabelPosition = lpLeft
    LabelSpacing = 20
    MaxLength = 20
    ParentFont = False
    TabOrder = 3
    Text = ''
    OnChange = lbePlayerChange
  end
  object BitBtnOk: TBitBtn
    Left = 62
    Top = 312
    Width = 89
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 4
  end
  object BitBtnAbbrechen: TBitBtn
    Left = 174
    Top = 312
    Width = 89
    Height = 25
    Caption = 'Abbrechen'
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 5
  end
end

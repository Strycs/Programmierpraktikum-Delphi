object frmCheatCard: TfrmCheatCard
  Left = 0
  Top = 0
  Caption = 'cheat Karte'
  ClientHeight = 167
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object BitBtnOk: TBitBtn
    Left = 105
    Top = 112
    Width = 73
    Height = 25
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 0
  end
  object BitBtnAbbrechen: TBitBtn
    Left = 201
    Top = 112
    Width = 89
    Height = 25
    Caption = 'Abbrechen'
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 1
  end
  object cbGameCard: TComboBox
    Left = 105
    Top = 48
    Width = 185
    Height = 23
    Style = csDropDownList
    TabOrder = 2
    Items.Strings = (
      'gcAnimals'
      'gcDiamond '
      'gcGoldCoin '
      'gcGuardian '
      'gcPirate '
      'gcPirateShip2 '
      'gcPirateShip3 '
      'gcPirateShip4 '
      'gcSkull1'
      'gcSkull2'
      'gcTreasureIsland')
  end
end

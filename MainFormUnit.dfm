object MainForm: TMainForm
  Left = 375
  Top = 243
  BorderIcons = [biSystemMenu, biMinimize, biHelp]
  BorderStyle = bsSingle
  ClientHeight = 257
  ClientWidth = 457
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 208
    Top = 200
    Width = 26
    Height = 13
    Caption = 'Keys:'
  end
  object Label2: TLabel
    Left = 200
    Top = 216
    Width = 35
    Height = 13
    Caption = 'Values:'
  end
  object Label3: TLabel
    Left = 248
    Top = 200
    Width = 3
    Height = 13
  end
  object Label4: TLabel
    Left = 248
    Top = 216
    Width = 3
    Height = 13
  end
  object Shot1Button: TButton
    Left = 16
    Top = 184
    Width = 81
    Height = 25
    Caption = '1st Shot'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = Shot1ButtonClick
  end
  object Shot2Button: TButton
    Left = 104
    Top = 184
    Width = 81
    Height = 25
    Caption = '2nd Shot'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = Shot2ButtonClick
  end
  object Memo: TMemo
    Left = 8
    Top = 16
    Width = 441
    Height = 153
    BevelInner = bvNone
    BevelOuter = bvNone
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object ClearButton: TButton
    Left = 104
    Top = 216
    Width = 81
    Height = 25
    Caption = 'Clear'
    Enabled = False
    TabOrder = 3
    OnClick = ClearButtonClick
  end
  object ShowResultsButton: TButton
    Left = 336
    Top = 184
    Width = 105
    Height = 57
    Caption = 'Show report'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = ShowResultsButtonClick
  end
  object HelpButton: TButton
    Left = 16
    Top = 216
    Width = 25
    Height = 25
    Caption = '?'
    TabOrder = 5
    OnClick = HelpButtonClick
  end
  object Timer: TTimer
    Interval = 100
    Left = 192
    Top = 216
  end
  object XPManifest: TXPManifest
    Left = 224
    Top = 216
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Plain text (*.txt)|*.txt'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Shot'
    Left = 256
    Top = 216
  end
end

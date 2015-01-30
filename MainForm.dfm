object Form1: TForm1
  Left = 336
  Top = 176
  BorderIcons = [biSystemMenu, biMinimize, biHelp]
  BorderStyle = bsSingle
  ClientHeight = 210
  ClientWidth = 455
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
    Top = 160
    Width = 26
    Height = 13
    Caption = 'Keys:'
  end
  object Label2: TLabel
    Left = 200
    Top = 176
    Width = 35
    Height = 13
    Caption = 'Values:'
  end
  object Label3: TLabel
    Left = 248
    Top = 160
    Width = 3
    Height = 13
  end
  object Label4: TLabel
    Left = 248
    Top = 176
    Width = 3
    Height = 13
  end
  object Button1: TButton
    Left = 16
    Top = 144
    Width = 81
    Height = 25
    Caption = 'Shot 1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 104
    Top = 144
    Width = 81
    Height = 25
    Caption = 'Shot 2'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = Button3Click
  end
  object Memo1: TMemo
    Left = 16
    Top = 16
    Width = 425
    Height = 113
    BevelInner = bvNone
    BevelOuter = bvNone
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object Button5: TButton
    Left = 104
    Top = 176
    Width = 81
    Height = 25
    Caption = 'Clear'
    Enabled = False
    TabOrder = 3
    OnClick = Button5Click
  end
  object Button4: TButton
    Left = 336
    Top = 144
    Width = 105
    Height = 57
    Caption = 'Show results'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = Button4Click
  end
  object Timer1: TTimer
    Interval = 100
    Left = 192
    Top = 176
  end
  object XPManifest1: TXPManifest
    Left = 224
    Top = 176
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Plain text (*.txt)|*.txt'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Shot'
    Left = 256
    Top = 176
  end
end

object FormMain: TFormMain
  Left = 192
  Top = 124
  Width = 1305
  Height = 675
  Caption = 'PasMP profiler (visible time period is quarter second)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 604
    Width = 1289
    Height = 32
    Align = alBottom
    TabOrder = 0
    object CheckBoxSuppressGaps: TCheckBox
      Left = 8
      Top = 8
      Width = 97
      Height = 17
      Caption = 'Suppress gaps'
      TabOrder = 0
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnIdle = ApplicationEvents1Idle
    Left = 256
    Top = 112
  end
end

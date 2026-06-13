object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'PasLLM App VCL- Copyright (C) 2025, Benjamin '#39'BeRo'#39' Rosseaux'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 185
    Top = 0
    Height = 422
    ExplicitLeft = 112
    ExplicitTop = 256
    ExplicitHeight = 100
  end
  object PanelLeft: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 422
    Align = alLeft
    TabOrder = 0
    object PanelLeftTop: TPanel
      Left = 1
      Top = 1
      Width = 183
      Height = 41
      Align = alTop
      TabOrder = 0
      ExplicitLeft = 96
      ExplicitTop = 120
      ExplicitWidth = 185
      object EditSessionName: TEdit
        Left = 1
        Top = 1
        Width = 181
        Height = 39
        Align = alClient
        TabOrder = 0
        OnExit = EditSessionNameExit
        OnKeyPress = EditSessionNameKeyPress
        ExplicitLeft = 48
        ExplicitTop = 24
        ExplicitWidth = 121
        ExplicitHeight = 23
      end
    end
    object PanelLeftBottom: TPanel
      Left = 1
      Top = 380
      Width = 183
      Height = 41
      Align = alBottom
      TabOrder = 1
      ExplicitLeft = 104
      ExplicitTop = 376
      ExplicitWidth = 185
      object ButtonNewSession: TButton
        Left = 1
        Top = 1
        Width = 181
        Height = 39
        Align = alClient
        Caption = 'New'
        TabOrder = 0
        OnClick = ButtonNewSessionClick
        ExplicitLeft = 136
        ExplicitTop = 8
        ExplicitWidth = 75
        ExplicitHeight = 25
      end
    end
    object ListBoxSessions: TListBox
      Left = 1
      Top = 42
      Width = 183
      Height = 338
      Align = alClient
      ItemHeight = 15
      TabOrder = 2
      OnClick = ListBoxSessionsClick
      OnDblClick = ListBoxSessionsDblClick
      OnKeyDown = ListBoxSessionsKeyDown
      ExplicitLeft = 104
      ExplicitTop = 272
      ExplicitWidth = 121
      ExplicitHeight = 97
    end
  end
  object PanelChat: TPanel
    Left = 188
    Top = 0
    Width = 436
    Height = 422
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 185
    ExplicitWidth = 439
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 422
    Width = 624
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 200
      end
      item
        Width = 200
      end
      item
        Width = 200
      end>
  end
end

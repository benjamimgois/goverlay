unit customeffectsunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TcustomeffectsForm }

  TcustomeffectsForm = class(TForm)
    ComboBox1: TComboBox;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    ComboBox8: TComboBox;
    effectsGroupBox: TGroupBox;
    fxaa1ComboBox: TComboBox;
    fxaa2ComboBox: TComboBox;
    fxaa3ComboBox: TComboBox;
    fxaaCheckBox: TCheckBox;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    smaaCheckBox: TCheckBox;
    smaaGroupBox: TGroupBox;
    procedure fxaaCheckBoxChange(Sender: TObject);
  private

  public

  end;

var
  customeffectsForm: TcustomeffectsForm;

implementation

{$R *.lfm}

{ TcustomeffectsForm }

procedure TcustomeffectsForm.fxaaCheckBoxChange(Sender: TObject);
begin

end;

end.


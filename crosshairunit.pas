unit crosshairUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type

  { TcrosshairsizeForm }

  TcrosshairsizeForm = class(TForm)
    crosshairTrackBar: TTrackBar;
    crosssizeLabel: TLabel;
    crosssizemaxLabel: TLabel;
    crosssizeminLabel: TLabel;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  crosshairsizeForm: TcrosshairsizeForm;

implementation

{$R *.lfm}

{ TcrosshairsizeForm }

procedure TcrosshairsizeForm.FormCreate(Sender: TObject);
begin
  //Centralize window
  Left:=(Screen.Width-Width)  div 2;
  Top:=(Screen.Height-Height) div 2;
end;

end.


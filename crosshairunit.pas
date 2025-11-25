unit crosshairUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, themeunit;

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
  // ============================================================================
  // FORM INSTANCE
  // ============================================================================
  crosshairsizeForm: TcrosshairsizeForm;  // Crosshair size configuration form

implementation

{$R *.lfm}

{ TcrosshairsizeForm }

procedure TcrosshairsizeForm.FormCreate(Sender: TObject);
begin
  //Centralize window
  CenterFormOnScreen(Self);
end;

end.


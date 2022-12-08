unit hudbackgroundUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls;

type

  { ThudbackgroundForm }

  ThudbackgroundForm = class(TForm)
    transparencyLabel: TLabel;
    transpmaxLabel: TLabel;
    transpminLabel: TLabel;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  hudbackgroundForm: ThudbackgroundForm;

implementation

{$R *.lfm}

{ ThudbackgroundForm }

procedure ThudbackgroundForm.FormCreate(Sender: TObject);
begin
  //Centralize window
  Left:=(Screen.Width-Width)  div 2;
  Top:=(Screen.Height-Height) div 2;
end;

end.


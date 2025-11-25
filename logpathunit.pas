unit logpathUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, process, themeunit;

type

  { TlogpathForm }

  TlogpathForm = class(TForm)
    changepathCheckBox: TCheckBox;
    SavecheckImage: TImage;
    setpathBitBtn: TBitBtn;
    homepathEdit: TEdit;
    pathLabel: TLabel;
    procedure changepathCheckBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure setpathBitBtnClick(Sender: TObject);
  private

  public

  end;

var
  // ============================================================================
  // FORM INSTANCE
  // ============================================================================
  logpathForm: TlogpathForm;            // Logging path configuration form

  // ============================================================================
  // LOG CONFIGURATION
  // ============================================================================
  destinationfolder: string;            // Selected destination folder for logs

implementation

{$R *.lfm}

{ TlogpathForm }

//Utilize overlayUnit in order know variable userhomepathSTR
uses overlayunit;

procedure TlogpathForm.FormCreate(Sender: TObject);
begin
  //Centralize window
  CenterFormOnScreen(Self);

  // Use Home path variable in Logging default Path
  logpathForm.homepathEdit.Text:=userhomepathSTR;
end;

procedure TlogpathForm.changepathCheckBoxChange(Sender: TObject);
begin
  if changepathCheckbox.Checked=true then
  begin
  homepathEdit.Enabled:=true;
  setpathBitBtn.Enabled:=true;
  end
  else
  begin
  homepathEdit.Enabled:=false;
  setpathBitBtn.Enabled:=false
  end;
end;


procedure TlogpathForm.setpathBitBtnClick(Sender: TObject);
begin
   //Store path in variable
  destinationfolder := homepathEdit.Text;
  SavecheckImage.Visible:=true;
  logpathForm.Close;
end;

end.


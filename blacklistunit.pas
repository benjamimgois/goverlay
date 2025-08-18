unit blacklistUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls;

type

  { TblacklistForm }

  TblacklistForm = class(TForm)
    blackListBox: TListBox;
    blacklistEdit: TEdit;
    iconsImageList: TImageList;
    Image1: TImage;
    insertblacklistBitBtn: TBitBtn;
    blacklistLabel: TLabel;
    removeblacklistBitBtn: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure insertblacklistBitBtnClick(Sender: TObject);
    procedure removeblacklistBitBtnClick(Sender: TObject);
  private

  public

  end;

var
blacklistForm: TblacklistForm;
BlacklistFile: string;
FileLines: TStringList;
SelectedIndex: Integer;

implementation

{$R *.lfm}

{ TblacklistForm }

// Function to get user config directory
function GetUserConfig(): String;
var
  UserConfig: String;
begin;
  UserConfig := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if not DirectoryExists(UserConfig) then
  begin
    UserConfig := GetUserDir + '.config';
  end;
  Result := UserConfig;
end;

procedure TblacklistForm.insertblacklistBitBtnClick(Sender: TObject);
begin
    // check if field is empty
  if Trim(blacklistedit.Text) = '' then
  begin
    ShowMessage('Insert a program name');
    Exit;
  end;

  // check for double values
  if blackListBox.Items.IndexOf(blacklistedit.Text) = -1 then
  begin
    blackListBox.Items.Add(blacklistedit.Text); // add to listbox
  end
  else
  begin
    ShowMessage('This program is already on the blacklist.');
    Exit;
  end;

  // Save new file
  FileLines := TStringList.Create;
  try
    FileLines.Assign(blackListBox.Items);
    ForceDirectories(ExtractFilePath(BlacklistFile)); // make sure directory exists
    FileLines.SaveToFile(BlacklistFile); // save file
  finally
    FileLines.Free;
  end;

  // clean edit field
  blacklistedit.Clear;

end;

procedure TblacklistForm.removeblacklistBitBtnClick(Sender: TObject);
begin
  BlacklistFile := GetUserConfig + '/goverlay/blacklist.conf';
  SelectedIndex := blackListBox.ItemIndex;

   // check if any item is selected
   if SelectedIndex = -1 then
   begin
     ShowMessage('Selecione um item para remover.');
     Exit;
   end;

   // Remove selected item
   blackListBox.Items.Delete(SelectedIndex);

   // save new list
   FileLines := TStringList.Create;
   try
     FileLines.Assign(blackListBox.Items);
     FileLines.SaveToFile(BlacklistFile);
   finally
     FileLines.Free;
   end;



end;

procedure TblacklistForm.FormShow(Sender: TObject);

begin
  BlacklistFile := GetUserConfig + '/goverlay/blacklist.conf';
  FileLines := TStringList.Create;
  try
    if FileExists(BlacklistFile) then
    begin
      // If file exists, load file in listbox
      FileLines.LoadFromFile(BlacklistFile);
    end
    else
    begin
      // if file doesnt exist, create a new one
      ForceDirectories(ExtractFilePath(BlacklistFile)); // Garante que o diretório existe
      FileLines.Add('zenity');
      FileLines.Add('protonplus');
      FileLines.Add('lsfg-vk-ui');
      FileLines.Add('bazzar');
      FileLines.Add('gnome-calculator');
      FileLines.Add('pamac-manager');
      FileLines.Add('lact');
      FileLines.Add('ghb');
      FileLines.Add('bitwig-studio');
      FileLines.Add('ptyxis');
      FileLines.Add('yumex');
      FileLines.SaveToFile(BlacklistFile);
    end;

    // Add items to listbox
    blackListBox.Items.Assign(FileLines);
  finally
    FileLines.Free;
  end;
end;


end.

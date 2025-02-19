unit blacklistUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TblacklistForm }

  TblacklistForm = class(TForm)
    blackListBox: TListBox;
    blacklistEdit: TEdit;
    iconsImageList: TImageList;
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

procedure TblacklistForm.insertblacklistBitBtnClick(Sender: TObject);
begin
    // Verifica se o campo de edição não está vazio
  if Trim(blacklistedit.Text) = '' then
  begin
    ShowMessage('Por favor, insira um nome válido.');
    Exit;
  end;

  // Verifica se o item já está na lista para evitar duplicatas
  if blackListBox.Items.IndexOf(blacklistedit.Text) = -1 then
  begin
    blackListBox.Items.Add(blacklistedit.Text); // Adiciona ao ListBox
  end
  else
  begin
    ShowMessage('Este programa já está na blacklist.');
    Exit;
  end;

  // Salva a nova lista no arquivo
  FileLines := TStringList.Create;
  try
    FileLines.Assign(blackListBox.Items);
    ForceDirectories(ExtractFilePath(BlacklistFile)); // Garante que o diretório existe
    FileLines.SaveToFile(BlacklistFile); // Salva no arquivo
  finally
    FileLines.Free;
  end;

  // Limpa o campo de edição após adicionar
  blacklistedit.Clear;



  //ShowMessage(IntToStr(blackListBox.Items.Count)); // Exibe a quantidade de itens carregados
end;

procedure TblacklistForm.removeblacklistBitBtnClick(Sender: TObject);
begin
  SelectedIndex := blackListBox.ItemIndex;

  // check if item is selected
  if SelectedIndex = -1 then
  begin
    ShowMessage('Select item to remove');
    Exit;
  end;



end;

procedure TblacklistForm.FormShow(Sender: TObject);

begin
  BlacklistFile := GetEnvironmentVariable('HOME') + '/.config/goverlay/blacklist.conf';
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
      ForceDirectories(ExtractFilePath(BlacklistFile)); // Garante que o diretÃ³rio existe
      FileLines.Add('pamac-manager'); // Opcional: adicionar uma entrada inicial
      FileLines.SaveToFile(BlacklistFile);
    end;

    // Add items to listbox
    blackListBox.Items.Assign(FileLines);
  finally
    FileLines.Free;
  end;
end;


end.


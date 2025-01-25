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
  private

  public

  end;

var
  blacklistForm: TblacklistForm;

implementation

{$R *.lfm}

end.


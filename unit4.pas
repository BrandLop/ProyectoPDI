unit Unit4;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TForm4 }

  TForm4 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ComboBox1: TComboBox;
    Label1: TLabel;
    procedure ComboBox1Change(Sender: TObject);
  private

  public
    gamval: double;

  end;

var
  Form4: TForm4;

implementation

{$R *.lfm}

{ TForm4 }

procedure TForm4.ComboBox1Change(Sender: TObject);
begin
  gamval := StrToFloat(ComboBox1.Text);
end;

end.

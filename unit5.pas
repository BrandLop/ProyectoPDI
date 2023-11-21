unit Unit5;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TForm5 }
  MATRGB = array of array of array of byte;

  TForm5 = class(TForm)
    Image1: TImage;
    ScrollBox1: TScrollBox;
  private

  public

  end;

var
  Form5: TForm5;
  BMAP3: Tbitmap;

implementation

{$R *.lfm}

end.


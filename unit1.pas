unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  ExtDlgs, LCLIntf, ComCtrls, Math, Unit2;

type



  { TForm1 }

  MATRGB = array of array of array of byte;
  //Tri-dimensional para almacenar contenido de imagen

  TForm1 = class(TForm)
    Image1: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    ScrollBox1: TScrollBox;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
  private

  public

    //copiar de imagen a Matriz con Canvas
    procedure copiaIM(al, an: integer; var M: MATRGB);

    //copiar de imagen a matriz con Scanline
    procedure copBM(al, an: integer; var M: MATRGB; B: Tbitmap);

    //copiar de Matriz a BITmap
    procedure copMB(al, an: integer; M: MATRGB; var B: Tbitmap);

    //linearizacion de valores del modelo XYZ
    procedure linearize(var Value: double);
    
  end;

var
  HistR, HistG, HistB: array[0..255] of integer;
  Form1: TForm1;
  ALTO, ANCHO: integer; //dimensiones de la imagen
  MAT: MATRGB;

  BMAP: Tbitmap;  //objeto orientado a directivas/metodos para .BMP

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem2Click(Sender: TObject);
begin

  if (OpenPictureDialog1.Execute) then        //si seleccionan un archivo BMP
  begin

    Image1.Enabled := True;
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
    ALTO := Image1.Height; //dimensiones de la imagen
    ANCHO := Image1.Width;

    //mostrar dimensiones en status bar
    StatusBar1.Panels[8].Text := IntToStr(ALTO) + 'x' + IntToStr(ANCHO);

    SetLength(MAT, ALTO, ANCHO, 3);     //especificar dimensiones de la matriz RGB
    copiaIM(ALTO, ANCHO, MAT); //copiar valores RGB a la MAtriz

  end;

end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
    Image1.Enabled := True;
    BMAP.LoadFromFile(OpenPictureDialog1.FileName);
    ALTO := BMAP.Height;
    ANCHO := BMAP.Width;

    if BMAP.PixelFormat <> pf24bit then   //garantizar 8 bits por canal
    begin
      BMAP.PixelFormat := pf24bit;
    end;

    StatusBar1.Panels[8].Text := IntToStr(ALTO) + 'x' + IntToStr(ANCHO);
    SetLength(MAT, ALTO, ANCHO, 3);
    copBM(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);  //visulaizar imagen
  end;

end;

procedure TForm1.MenuItem5Click(Sender: TObject);
var
  i, j: integer;
  k: byte;
begin
  //filtro negativo
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
    begin
      for k := 0 to 2 do
      begin
        MAT[i, j, k] := 255 - MAT[i, j, k];
      end;  //k
    end;    //j
  end; //i

  copMB(ALTO, ANCHO, MAT, BMAP);
  //visualizar resultado
  Image1.Picture.Assign(BMAP);
end;

procedure TForm1.linearize(var Value: double);
var
  aux: double;
begin
  if Value <= 0.04045 then
  begin
    Value := Value / 12.92;
  end
  else
  begin
    aux := ((Value + 0.055) / 1.055);
    Value := Power(aux, 2.4);
  end;
end;


procedure TForm1.MenuItem7Click(Sender: TObject);
var
  i, j: integer;
  r, g, b, x, y, z, rga, gga, bga: double;
  k: byte;
begin
  //cambio de modelo de color
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
    begin
      //normalizacion de valores entre 0 y 1
      r := MAT[i, j, 0] / 255;
      g := MAT[i, j, 1] / 255;
      b := MAT[i, j, 2] / 255;

      //linearizacion de los canales
      linearize(r);
      linearize(g);
      linearize(b);

      //Conversion rgb a xyz
      X := R * 0.412453 + G * 0.357580 + B * 0.180423;
      Y := R * 0.212671 + G * 0.715160 + B * 0.072169;
      Z := R * 0.019334 + G * 0.119193 + B * 0.950227;

      //X := rga * 0.412453 + gga * 0.357580 + bga * 0.180423;
      //Y := rga * 0.212671 + gga * 0.715160 + bga * 0.072169;
      //Z := rga * 0.019334 + gga * 0.119193 + bga * 0.950227;
      //Normalizar los valores con mix max
      //X := (X - 0)/(255 - 0);
      //Y := (Y - 0)/(255 - 0);
      //Z := (Z - 0)/(255 - 0);
      //Normalizar los valores
      X := X * 255;
      Y := Y * 255;
      Z := Z * 255;
      //asignar los valores
      MAT[i, j, 0] := Round(X);
      MAT[i, j, 1] := Round(Y);
      MAT[i, j, 2] := Round(Z);
    end;    //j
  end; //i

  copMB(ALTO, ANCHO, MAT, BMAP);
  //visualizar resultado
  Image1.Picture.Assign(BMAP);
end;

//histograma
procedure TForm1.MenuItem9Click(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  BMAP := TBitmap.Create;  //crear el objeto BMAP

end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  //al mover el mouse, indica las coordenadas X Y

  StatusBar1.Panels[1].Text := IntToStr(X);
  StatusBar1.Panels[2].Text := IntToStr(Y);
  StatusBar1.Panels[4].Text := IntToStr(MAT[y, x, 0]);
  StatusBar1.Panels[5].Text := IntToStr(MAT[y, x, 1]);
  StatusBar1.Panels[6].Text := IntToStr(MAT[y, x, 2]);

end;

procedure Tform1.copiaIM(al, an: integer; var M: MATRGB);
//copiar el contenido de la imagen a una MAtriz
var
  i, j: integer;
  cl: Tcolor;

begin

  for i := 0 to al - 1 do
  begin
    for j := 0 to an - 1 do
    begin
      cl := Image1.Canvas.Pixels[j, i]; //leer valor total de color del pixel j,i
      MAT[i, j, 0] := GetRValue(cl);
      MAT[i, j, 1] := GetGValue(cl);
      MAT[i, j, 2] := GetBValue(cl);

    end; //j
  end;//i

end;


//copiar de Bitmap a Matriz

procedure Tform1.copBM(al, an: integer; var M: MATRGB; B: Tbitmap);
var
  i, j, k: integer;
  P: Pbyte;
begin
  for i := 0 to al - 1 do
  begin
    B.BeginUpdate;
    P := B.ScanLine[i];  //ller RGB de todo el renglon-i
    B.EndUpdate;

    for j := 0 to an - 1 do
    begin
      k := 3 * j;
      MAT[i, j, 0] := P[k + 2];
      MAT[i, j, 1] := P[k + 1];
      MAT[i, j, 2] := P[k];

    end; //j
  end; //i

end;

//procedimiento para copiar de MAtriz a bitmap

procedure tform1.copMB(al, an: integer; M: MATRGB; var B: Tbitmap);
var
  i, j, k: integer;
  P: Pbyte;
begin
  for i := 0 to al - 1 do
  begin
    B.BeginUpdate;
    P := B.ScanLine[i];
    //Invocar método para tener listo en memoria la localidad a modificar--> toda la fila
    B.EndUpdate;

    for j := 0 to an - 1 do
    begin             //asignando valores de matriz al apuntador scanline--> Bitmap
      k := 3 * j;
      P[k + 2] := MAT[i, j, 0];
      P[k + 1] := MAT[i, j, 1];
      P[k] := MAT[i, j, 2];

    end; //j
  end; //i
end;

end.

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  ExtDlgs, LCLIntf, ComCtrls, StdCtrls, Math, Unit2, Unit3, Unit4, unit5;

type



  { TForm1 }

  MATRGB = array of array of array of byte;
  //Tri-dimensional para almacenar contenido de imagen
  TNumeroComplejo = record
    Re: Double;
    Im: Double;
  end;

  TForm1 = class(TForm)
    ColorDialog1: TColorDialog;
    Image1: TImage;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    LBP: TMenuItem;
    LBPTHRESHOLD: TMenuItem;
    LBPSTD: TMenuItem;
    Bordes: TMenuItem;
    Erosion: TMenuItem;
    ProgressBar1: TProgressBar;
    Salir: TMenuItem;
    Morfologicos: TMenuItem;
    ReduxContrast: TMenuItem;
    SavePictureDialog1: TSavePictureDialog;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    Tanhip: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    FiltroNegativo: TMenuItem;
    MenuItem6: TMenuItem;
    colorxyz: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    ScrollBox1: TScrollBox;
    StatusBar1: TStatusBar;
    procedure ErosionClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure LBPSTDClick(Sender: TObject);
    procedure LBPTHRESHOLDClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure FiltroNegativoClick(Sender: TObject);
    procedure colorxyzClick(Sender: TObject);
    procedure HistogramaaClick(Sender: TObject);
    procedure BordesClick(Sender: TObject);
    procedure ReduxContrastClick(Sender: TObject);
    procedure SalirClick(Sender: TObject);
    procedure TanhipClick(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton12Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure ToolButton14Click(Sender: TObject);
    procedure ToolButton15Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
  private
    xpoint: integer;
    ypoint: integer;
  const
    Weights: array[0..2, 0..2] of byte = (
      (1, 2, 4),
      (128, 0, 8),
      (64, 32, 16)
      );

  public

    //copiar de imagen a Matriz con Canvas
    procedure copiaIM(al, an: integer; var M: MATRGB);

    //copiar de imagen a matriz con Scanline
    procedure copBM(al, an: integer; var M: MATRGB; B: Tbitmap);

    //copiar de Matriz a BITmap
    procedure copMB(al, an: integer; M: MATRGB; var B: Tbitmap);

    //linearizacion de valores del modelo XYZ
    procedure linearize(var Value: double);

    //procedimiento para generar histograma
    procedure histograma(M: MATRGB);

    procedure escala_de_grises();

    procedure binarizacionDi();

    procedure gammaFilter(gamaval: double);

    procedure tanhyper(alphaval: double);

    procedure copMAM(var OriMAT: MATRGB; var AuxiMAT: MATRGB);

    procedure RotateImage(var OriginalMAT: MATRGB; var RotatedMAT: MATRGB;
      AngleDegrees: double);

    procedure lbpMaxValue();
    procedure lbpSTDTHRES();
    procedure gradient();
    procedure pattern();
    procedure generatecolscheme();
    procedure erosionate();
    procedure binarize();
    procedure TFourier();
    procedure espectroFou();
    procedure viewEspectro();
  end;

var
  HistR, HistG, HistB: array[0..255] of integer;
  Form1: TForm1;
  ALTO, ANCHO, NewAncho, NewAlto: integer; //dimensiones de la imagen
  MAT, AuxMAT, AuxMAT2: MATRGB;
  BMAP, BMAP2: Tbitmap;  //objeto orientado a directivas/metodos para .BMP
  pathFile: string;
  counter: shortint = 0;
  grades: double = 0.0;
  colorscheme: array[0..255] of array[0..2] of byte;
  P1, P2: TPoint;
  ClickEnabled: boolean = False;
  CounterL: byte = 0;
  counterR: byte = 0;
  countL: byte = 0;
  countR: byte = 0;
  firsterosion: boolean = True;
  points: array[0..3] of integer;
  FMAT: array of array of TNumeroComplejo;
  magnitudes: array of array of Double;

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

procedure TForm1.FiltroNegativoClick(Sender: TObject);
var
  i, j: integer;
  k: byte;
begin
  //filtro negativo
  for i := P1.Y to P2.Y - 1 do
  begin
    for j := P1.X to P2.X - 1 do
    begin
      for k := 0 to 2 do
      begin
        MAT[i, j, k] := 255 - MAT[i, j, k];
      end;  //k
    end;    //j
  end; //i
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
  histograma(MAT);
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

//cambio a modelo xyz
procedure TForm1.colorxyzClick(Sender: TObject);
var
  i, j: integer;
  r, g, b, x, y, z: double;
begin
  //cambio de modelo de color
  for i := P1.Y to P2.Y - 1 do
  begin
    for j := P1.X to P2.X - 1 do
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
  histograma(MAT);
end;

//histograma
procedure TForm1.HistogramaaClick(Sender: TObject);
begin
  histograma(MAT);
end;

procedure TForm1.BordesClick(Sender: TObject);
begin
  gradient();
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
  histograma(MAT);
end;

procedure TForm1.pattern();
var
  i, j, al, an, res: integer;
  k: byte;
  AuxMAT2: MATRGB;
begin
  BMAP2 := TBitmap.Create;
  BMAP2.LoadFromFile('./patron.bmp');
  al := Min(ALTO, BMAP2.Height);
  an := Min(ANCHO, BMAP2.Width);
  SetLength(AuxMAT, al, an, 3);
  SetLength(AuxMAT2, al, an, 3);
  copBM(al, an, AuxMAT, BMAP2);
  for i := 0 to al - 1 do
  begin
    for j := 0 to an - 1 do
    begin
      for k := 0 to 2 do
      begin
        res := MAT[i, j, k] - AuxMAT[i, j, k];
        if res <= 0 then
        begin
          AuxMAT2[i, j, k] := 0;
        end
        else
        begin
          AuxMAT2[i, j, k] := res;
        end;
      end;
    end;
  end;
  ALTO := al;
  ANCHO := an;
  BMAP.Width := ANCHO;
  BMAP.Height := ALTO;
  copMAM(MAT, AuxMAT2);
end;

procedure TForm1.ReduxContrastClick(Sender: TObject);
var
  i, j: integer;
  minR, maxR, minG, maxG, minB, maxB: byte;
begin
  Unit2.ClickEnabled := True;
  Form2.Hide;
  Form2.Caption := 'Reducción de Contraste';
  Form2.Chart1.Cursor := crCross;
  Form2.ShowModal;
  if Form2.resp = 1 then
  begin
    minR := MAT[0, 0, 0];
    minG := MAT[0, 0, 1];
    minB := MAT[0, 0, 2];
    maxR := MAT[0, 0, 0];
    maxG := MAT[0, 0, 1];
    maxB := MAT[0, 0, 2];
    for i := P1.Y to P2.Y - 1 do
    begin
      for j := P1.X to P2.X - 1 do
      begin
        if MAT[i, j, 0] > maxR then
        begin
          maxR := MAT[i, j, 0];
        end
        else if MAT[i, j, 0] < minR then
        begin
          minR := MAT[i, j, 0];
        end;
        if MAT[i, j, 1] > maxG then
        begin
          maxG := MAT[i, j, 1];
        end
        else if MAT[i, j, 1] < minG then
        begin
          minG := MAT[i, j, 1];
        end;
        if MAT[i, j, 2] > maxB then
        begin
          maxB := MAT[i, j, 2];
        end
        else if MAT[i, j, 2] < minB then
        begin
          minB := MAT[i, j, 2];
        end;
      end;
    end;
    for i := P1.Y to P2.Y - 1 do
    begin
      for j := P1.X to P2.X - 1 do
      begin
        MAT[i, j, 0] := Round((Form2.nmaxval - Form2.nminval) /
          (maxR - minR) * (MAT[i, j, 0] - minR) + Form2.nminval);
        MAT[i, j, 1] := Round((Form2.nmaxval - Form2.nminval) /
          (maxG - minG) * (MAT[i, j, 1] - minG) + Form2.nminval);
        MAT[i, j, 2] := Round((Form2.nmaxval - Form2.nminval) /
          (maxB - minB) * (MAT[i, j, 2] - minB) + Form2.nminval);
      end;
    end;
    copMB(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);
    histograma(MAT);
  end;
  if Form2.resp = 2 then
  begin
  end;
  Form2.Chart1.Cursor := crDefault;
  Form2.Show;
  Unit2.ClickEnabled := False;
  Form2.Caption := 'Histograma';
end;

procedure TForm1.SalirClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.generatecolscheme();
var
  i: integer;
  t: double;
  colors: array[0..3] of array[0..2] of byte;
  colorSelected: TColor;
  r, g, b: byte;
begin
  for i := 0 to 3 do
  begin
    if ColorDialog1.Execute then
    begin
      colorSelected := ColorDialog1.Color;
      colors[i, 0] := GetRValue(colorSelected);
      colors[i, 1] := GetGValue(colorSelected);
      colors[i, 2] := GetBValue(colorSelected);
    end;
  end;

  for i := 0 to 85 - 1 do
  begin
    t := i / 85;
    r := Round((1 - t) * colors[0, 0] + t * colors[1, 0]);
    g := Round((1 - t) * colors[0, 1] + t * colors[1, 1]);
    b := Round((1 - t) * colors[0, 2] + t * colors[1, 2]);
    colorscheme[i, 0] := r;
    colorscheme[i, 1] := g;
    colorscheme[i, 2] := b;
  end;
  for i := 0 to 85 - 1 do
  begin
    t := i / 85;
    r := Round((1 - t) * colors[1, 0] + t * colors[2, 0]);
    g := Round((1 - t) * colors[1, 1] + t * colors[2, 1]);
    b := Round((1 - t) * colors[1, 2] + t * colors[2, 2]);
    colorscheme[i + 85, 0] := r;
    colorscheme[i + 85, 1] := g;
    colorscheme[i + 85, 2] := b;
  end;
  for i := 0 to 85 - 1 do
  begin
    t := i / 85;
    r := Round((1 - t) * colors[2, 0] + t * colors[3, 0]);
    g := Round((1 - t) * colors[2, 1] + t * colors[3, 1]);
    b := Round((1 - t) * colors[2, 2] + t * colors[3, 2]);
    colorscheme[i + 170, 0] := r;
    colorscheme[i + 170, 1] := g;
    colorscheme[i + 170, 2] := b;
  end;
  colorscheme[255, 0] := colors[3, 0];
  colorscheme[255, 1] := colors[3, 1];
  colorscheme[255, 2] := colors[3, 2];
end;

procedure TForm1.tanhyper(alphaval: double);
var
  i, j: integer;
  k: byte;
  Value: double;
begin
  for i := P1.Y to P2.Y - 1 do
  begin
    for j := P1.X to P2.X - 1 do
    begin
      for k := 0 to 2 do
      begin
        Value := 255 / 2 * (1 + TanH(alphaval * (MAT[i, j, k] - (255 / 2))));
        MAT[i, j, k] := Round(Value);
      end;
    end;
  end;
end;

procedure TForm1.TanhipClick(Sender: TObject);
begin
  Form4.ComboBox1.Text := 'Valor de alfa';
  Form4.ShowModal;
  if Form4.ModalResult = mrOk then
  begin
    tanhyper(Form4.gamval);
    copMB(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);
    histograma(MAT);
  end;
end;

procedure TForm1.ToolButton10Click(Sender: TObject);
begin
  histograma(MAT);
end;

procedure TForm1.ToolButton11Click(Sender: TObject);
var
  i, j, x, y: integer;
  k: byte;
  sum: double;
  temp: array[0..2, 0..2] of double;
const
  MascaraSuavizado: array[0..2, 0..2] of single = (
    (1 / 8, 1 / 8, 1 / 8),
    (1 / 8, 1 / 8, 1 / 8),
    (1 / 8, 1 / 8, 1 / 8)
    );
begin
  //SetLength(AuxMAT, ALTO, ANCHO, 3);
  copMAM(AuxMAT, MAT);
  for i := P1.Y + 1 to P2.Y - 2 do
  begin
    for j := P1.X + 1 to P2.X - 2 do
    begin
      for k := 0 to 2 do
      begin
        sum := 0;
        for x := -1 to 1 do
        begin
          for y := -1 to 1 do
          begin
            if (x <> 0) or (y <> 0) then
            begin
              temp[x + 1, y + 1] :=
                MAT[i + x, j + y, k] * MascaraSuavizado[x + 1, y + 1];
              sum := sum + temp[x + 1, y + 1];
            end;
          end;
        end;
        AuxMAT[i, j, k] := Round(sum);
      end;
    end;
  end;
  copMAM(MAT, AuxMAT);
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
  histograma(MAT);
end;

procedure TForm1.ToolButton12Click(Sender: TObject);
begin
  if SavePictureDialog1.Execute then
  begin
    BMAP.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

procedure TForm1.ToolButton13Click(Sender: TObject);
begin
  pattern();
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
  histograma(MAT);
end;

procedure TForm1.ToolButton14Click(Sender: TObject);
begin
  ClickEnabled := False;
  P1.X := 0;
  P1.Y := 0;
  P2.X := ANCHO;
  P2.Y := ALTO;
  StatusBar1.Panels[10].Text := '';
  StatusBar1.Panels[11].Text := '';
end;

procedure TForm1.TFourier();
var
  n,m,u,v,ut,vt: Integer;
  sumReal, sumIm, phiu, phiv, cosw, senw, s :  Real;
begin
  //factor escalar común.
  s := 1/sqrt(ANCHO * ALTO);
  for u:=0 to ALTO-1 do
  begin
    for v:=0 to ANCHO-1 do
    begin
      sumReal := 0;
      sumIm := 0;
      ut := u - floor(ALTO/2);
      vt := v - floor(ANCHO/2);
      //factores comunes
      phiu := 2 * Pi * ut/ALTO;
      phiv := 2 * Pi * vt/ANCHO;
      for n:=0 to ALTO-1 do
      begin
        for m:=0 to ANCHO-1 do
        begin
          cosw := cos(phiu*n + phiv*m);
          senw := sin(phiu*n + phiv*m);
          sumReal := sumReal + MAT[n,m,0] * cosw + MAT[n,m,0] * senw;
          sumIm := sumIm + MAT[n,m,0] * cosw - MAT[n,m,0] * senw;
        end;
      end;
      FMAT[u,v].Re := sumReal * s;
      FMAT[u,v].Im := sumIm * s;
    end;
  end;
  ProgressBar1.Position:=100;
end;

procedure TForm1.espectroFou();
var
  u,v: Integer;
  maxVal, minVal: Double;
  loga: double;
begin
  maxVal := -MaxDouble;
  minVal := MaxDouble;
  for u:=0 to ALTO-1 do
  begin
    for v:=0 to ANCHO-1 do
    begin
      magnitudes[u,v] := Sqrt(sqr(FMAT[u,v].Re)+ sqr(FMAT[u,v].Im));
      maxVal := Max(maxVal, magnitudes[u,v]);
      minVal := Min(minVal, magnitudes[u,v]);
    end;
  end;
  for u:=0 to ALTO-1 do
  begin
    for v:=0 to ANCHO-1 do
    begin
      loga := ln(magnitudes[u,v] + 1);
      magnitudes[u,v] := (loga - ln(loga + 1)) / (ln(maxVal + 1) - ln(minVal + 1)) * 255;
    end;
  end;
end;

procedure TForm1.viewEspectro();
var
  i, j: integer;
  k: byte;
  espectro: MATRGB;
begin
  SetLength(espectro, ALTO, ANCHO,3);
  for i := 0 to ALTO-1 do
  begin
    for j := 0 to ANCHO-1 do
    begin
      for k := 0 to 2 do
      begin
        espectro[i,j,k] := Round(magnitudes[i,j]);
      end;
    end;
  end;
  copMB(ALTO, ANCHO, espectro, BMAP);
  Form5.Image1.Picture.Assign(BMAP);
end;

procedure TForm1.ToolButton15Click(Sender: TObject);
begin
  SetLength(FMAT, ALTO, ANCHO);
  SetLength(magnitudes, ALTO, ANCHO);
  TFourier();
  espectroFou();
  viewEspectro();
  Form5.ShowModal;
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
    Image1.Enabled := True;
    pathFile := OpenPictureDialog1.FileName;
    BMAP.LoadFromFile(pathFile);
    ALTO := BMAP.Height;
    ANCHO := BMAP.Width;

    if BMAP.PixelFormat <> pf24bit then   //garantizar 8 bits por canal
    begin
      BMAP.PixelFormat := pf24bit;
    end;

    P1.X := 0;
    P1.Y := 0;
    P2.X := ANCHO;
    P2.Y := ALTO;

    firsterosion := True;

    StatusBar1.Panels[8].Text := IntToStr(ALTO) + 'x' + IntToStr(ANCHO);
    SetLength(MAT, ALTO, ANCHO, 3);
    copBM(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);  //visulaizar imagen
    histograma(MAT);
    ToolButton2.Enabled := True;
    ToolButton3.Enabled := True;
    ToolButton4.Enabled := True;
    ToolButton5.Enabled := True;
    ToolButton6.Enabled := True;
    ToolButton7.Enabled := True;
    ToolButton8.Enabled := True;
    ToolButton9.Enabled := True;
    ToolButton10.Enabled := True;
    ToolButton11.Enabled := True;
    ToolButton12.Enabled := True;
    ToolButton13.Enabled := True;
    ToolButton14.Enabled := True;
    ToolButton15.Enabled := True;
    MenuItem3.Enabled := True;
    MenuItem6.Enabled := True;
    Morfologicos.Enabled := True;
    ProgressBar1.Position:=0;
  end;
end;

procedure TForm1.ToolButton2Click(Sender: TObject);
begin
  BMAP.LoadFromFile(pathFile);
  ALTO := BMAP.Height;
  ANCHO := BMAP.Width;
  if BMAP.PixelFormat <> pf24bit then   //garantizar 8 bits por canal
  begin
    BMAP.PixelFormat := pf24bit;
  end;
  counter := 0;
  grades := 0.0;
  StatusBar1.Panels[8].Text := IntToStr(ALTO) + 'x' + IntToStr(ANCHO);
  SetLength(MAT, ALTO, ANCHO, 3);
  copBM(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);  //visulaizar imagen
  histograma(MAT);
  ProgressBar1.Position:=0;
end;

procedure TForm1.ToolButton3Click(Sender: TObject);
begin
  escala_de_grises();
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
  histograma(MAT);
end;

procedure TForm1.ToolButton4Click(Sender: TObject);
begin
  ClickEnabled := True;
  StatusBar1.Panels[10].Text := 'Modo Selección';
end;

procedure TForm1.ToolButton5Click(Sender: TObject);
begin
  if counter <= 3 then
  begin
    SetLength(AuxMAT, 0, 0, 0);
    grades := 90.0;
    RotateImage(MAT, AuxMAT, grades);
    copMAM(MAT, AuxMAT);
    copMB(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);
    if counter = 3 then
    begin
      grades := 0.0;
      counter := -1;
    end;
  end;
  counter := counter + 1;
end;

procedure TForm1.ToolButton6Click(Sender: TObject);
begin
  if counter >= -3 then
  begin
    SetLength(AuxMAT, 0, 0, 0);
    grades := -90.0;
    RotateImage(MAT, AuxMAT, grades);
    copMAM(MAT, AuxMAT);
    copMB(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);
    if counter = -3 then
    begin
      grades := 0.0;
      counter := 1;
    end;
  end;
  counter := counter - 1;
end;

procedure TForm1.ToolButton7Click(Sender: TObject);
var
  i, j, k, midpoin, auxval: integer;
begin
  copMAM(AuxMAT, MAT);
  midpoin := ANCHO div 2;
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to midpoin - 1 do
    begin
      for k := 0 to 2 do
      begin
        MAT[i, (midpoin - 1 - j), k] := AuxMAT[i, j, k];
      end;
    end;
  end;
  for i := 0 to ALTO - 1 do
  begin
    auxval := 0;
    for j := midpoin to ANCHO - 1 do
    begin
      for k := 0 to 2 do
      begin
        MAT[i, (ANCHO - 1 - auxval), k] := AuxMAT[i, j, k];
      end;
      auxval := auxval + 1;
    end;
  end;
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
end;

procedure TForm1.ToolButton8Click(Sender: TObject);
begin
  Form4.ShowModal;
  if Form4.ModalResult = mrOk then
  begin
    gammaFilter(Form4.gamval);
    copMB(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);
    histograma(MAT);
  end;
end;

procedure TForm1.ToolButton9Click(Sender: TObject);
var
  dist1, dist2: double;
begin
  dist1 := sqrt((P2.X - P1.X) * (P2.X - P1.X) + (P1.Y - P1.Y) * (P1.Y - P1.Y));
  dist2 := sqrt((P1.X - P1.X) * (P1.X - P1.X) + (P2.Y - P1.Y) * (P2.Y - P1.Y));
  if dist1 = dist2 then
  begin
    Form3.TrackBar1.Min := 3;
    Form3.TrackBar1.Max := Round(dist1);
    Form3.ShowModal;
    if Form3.ModalResult = mrOk then
    begin
      escala_de_grises();
      binarizacionDi();
      copMB(ALTO, ANCHO, MAT, BMAP);
      Image1.Picture.Assign(BMAP);
      histograma(MAT);
    end;
  end
  else
  begin
    ShowMessage('La imagen no tiene las mismas dimensiones en alto y ancho :(');
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  BMAP := TBitmap.Create;  //crear el objeto BMAP
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if ClickEnabled then
  begin
    if Button = mbLeft then
    begin
      points[0] := X;
      points[1] := Y;
      CounterL := 1;
    end;
    if Button = mbRight then
    begin
      points[2] := X;
      points[3] := Y;
      counterR := 1;
    end;
    if (CounterL = 1) and (counterR = 1) then
    begin
      P1.X := Min(points[0], points[2]);
      P2.X := Max(points[0], points[2]);
      P1.Y := Min(points[1], points[3]);
      P2.Y := Max(points[1], points[3]);
      CounterL := 0;
      counterR := 0;
    end;
  end;
end;

procedure TForm1.escala_de_grises();
var
  i, j: integer;
  k: byte;
begin
  //filtro escala de grises, promedio de los valores de los canales R=G=B
  for i := P1.Y to P2.Y - 1 do
  begin
    for j := P1.X to P2.X - 1 do
    begin
      k := (MAT[i, j, 0] + MAT[i, j, 1] + MAT[i, j, 2]) div 3;
      MAT[i, j, 0] := k;
      MAT[i, j, 1] := k;
      MAT[i, j, 2] := k;
    end;
  end;
end;

procedure TForm1.binarizacionDi();
var
  sumatoria, threshold, i, j, k, l, rsize, m: integer;
begin
  m := Form3.rsize;
  i := P1.Y;
  while i <= P2.Y - 1 do
  begin
    j := P1.X;
    while j <= P2.Y - 1 do
    begin
      sumatoria := 0;
      Rsize := 0;
      for k := i to Min(i + m - 1, P2.Y - 1) do
      begin
        for l := j to Min(j + m - 1, P2.Y - 1) do
        begin
          sumatoria := sumatoria + MAT[k, l, 0];
          Rsize := Rsize + 1;
        end;
      end;
      threshold := sumatoria div Rsize;
      for k := i to Min(i + m - 1, P2.Y - 1) do
      begin
        for l := j to Min(j + m - 1, P2.Y - 1) do
        begin
          if MAT[k, l, 0] > threshold then
          begin
            MAT[k, l, 0] := 255;
            MAT[k, l, 1] := 255;
            MAT[k, l, 2] := 255;
          end
          else
          begin
            MAT[k, l, 0] := 0;
            MAT[k, l, 1] := 0;
            MAT[k, l, 2] := 0;
          end;
        end;
      end;
      j := j + m;
    end;
    i := i + m;
  end;
end;

procedure TForm1.gammaFilter(gamaval: double);
var
  i, j, k: integer;
  res: double;
begin
  for i := P1.Y to P2.Y - 1 do
  begin
    for j := P1.X to P2.X - 1 do
    begin
      for k := 0 to 2 do
      begin
        res := Power((MAT[i, j, k] / 255), gamaval) * 255;
        MAT[i, j, k] := Round(res);
      end;
    end;
  end;
end;

procedure TForm1.copMAM(var OriMAT: MATRGB; var AuxiMAT: MATRGB);
var
  i, j, k: integer;
begin
  SetLength(OriMAT, 0, 0, 0);
  ALTO := Length(AuxiMAT);
  ANCHO := Length(AuxiMAT[0]);
  SetLength(OriMAT, ALTO, ANCHO, 3);
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
    begin
      for k := 0 to 2 do
      begin
        OriMAT[i, j, k] := AuxiMAT[i, j, k];
      end;
    end;
  end;
end;

procedure TForm1.RotateImage(var OriginalMAT: MATRGB; var RotatedMAT: MATRGB;
  AngleDegrees: double);
var
  centerX, centerY, newX, newY: integer;
  i, j, k: integer;
  cosine, sine: double;
begin
  AngleDegrees := AngleDegrees * (PI / 180); // Convert degrees to radians
  cosine := Cos(AngleDegrees);
  sine := Sin(AngleDegrees);

  NewAncho := Round(Abs(ANCHO * cosine) + Abs(ALTO * sine));
  NewAlto := Round(Abs(ANCHO * sine) + Abs(ALTO * cosine));
  SetLength(RotatedMAT, NewAlto, NewAncho, 3);

  centerX := ANCHO div 2;
  centerY := ALTO div 2;

  BMAP.Width := NewAncho;
  BMAP.Height := NewAlto;

  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
    begin
      for k := 0 to 2 do
      begin
        newX := Round((j - centerX) * cosine - (i - centerY) * sine) + NewAncho div 2;
        newY := Round((j - centerX) * sine + (i - centerY) * cosine) + NewAlto div 2;

        if (newX >= 0) and (newX < NewAncho) and (newY >= 0) and (newY < NewAlto) then
        begin
          RotatedMAT[newY, newX, k] := OriginalMAT[i, j, k];
        end;
      end;
    end;
  end;
end;

procedure TForm1.binarize();
var
  sumatoria, threshold, i, j: integer;
begin
  sumatoria := 0;
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
    begin
      sumatoria := sumatoria + MAT[i, j, 0];
    end;
  end;
  threshold := sumatoria div (ALTO * ANCHO);
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
    begin
      if MAT[i, j, 0] > threshold then
      begin
        MAT[i, j, 0] := 255;
        MAT[i, j, 1] := 255;
        MAT[i, j, 2] := 255;
      end
      else
      begin
        MAT[i, j, 0] := 0;
        MAT[i, j, 1] := 0;
        MAT[i, j, 2] := 0;
      end;
    end;
  end;
end;

procedure TForm1.erosionate();
var
  i, j, x, y: integer;
  sum: byte;
const
  Estructura: array[0..2, 0..2] of byte = (
    (1, 0, 1),
    (0, 0, 0),
    (1, 0, 1)
    );
begin
  if firsterosion then
  begin
    SetLength(AuxMAT, ALTO, ANCHO, 3);
    copMAM(AuxMAT2, MAT);
    firsterosion := False;
  end;
  for i := 1 to ALTO - 2 do
  begin
    for j := 1 to ANCHO - 2 do
    begin
      sum := 0;
      for x := -1 to 1 do
      begin
        for y := -1 to 1 do
        begin
          if (AuxMAT2[i + x, j + y, 0] = Estructura[x + 1, y + 1]) and
            (Estructura[x + 1, y + 1] = 0) then
          begin
            sum := sum + 1;
          end;
        end;
      end;
      if sum = 5 then
      begin
        AuxMAT[i, j, 0] := 0;
        AuxMAT[i, j, 1] := 0;
        AuxMAT[i, j, 2] := 0;
      end
      else
      begin
        AuxMAT[i, j, 0] := 255;
        AuxMAT[i, j, 1] := 255;
        AuxMAT[i, j, 2] := 255;
      end;
    end;
  end;
  copMAM(AuxMAT2, AuxMAT);
  copMB(ALTO, ANCHO, AuxMAT, BMAP);
  Form5.Image1.Picture.Assign(BMAP);
end;

procedure TForm1.ErosionClick(Sender: TObject);
begin
  binarize();
  erosionate();
  histograma(AuxMAT);
  Form5.Show;
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

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if ClickEnabled then
  begin
    if Button = mbLeft then
    begin
      ShowMessage('Primer punto: ' + IntToStr(X) + ', ' + IntToStr(Y));
      countL := 1;
    end;
    if Button = mbRight then
    begin
      ShowMessage('Segundo punto: ' + IntToStr(X) + ', ' + IntToStr(Y));
      countR := 1;
    end;
    if (countL = 1) and (countR = 1) then
    begin
      ShowMessage('Ahora puede aplicar ciertos filtros a la región seleccionada :)');
      StatusBar1.Panels[11].Text :=
        'Región Selec: ' + IntToStr(P2.Y - P1.Y) + 'x' + IntToStr(P2.X - P1.X);
      countL := 0;
      countR := 0;
    end;
  end;
end;

procedure TForm1.lbpSTDTHRES();
var
  i, j, x, y: integer;
  max, sum, k: byte;
  stad: double;
  MATColor: MATRGB;
  values: array[0..7] of double;
  temp: array[0..2, 0..2] of byte;
begin
  copMAM(MATColor, MAT);
  copMAM(AuxMAT, MAT);
  for i := P1.Y + 1 to P2.Y - 2 do
  begin
    for j := P1.X + 1 to P2.X - 2 do
    begin
      k := 0;
      sum := 0;
      for x := -1 to 1 do
      begin
        for y := -1 to 1 do
        begin
          if (x <> 0) or (y <> 0) then
          begin
            values[k] := MAT[i + x, j + y, 0];
            k := k + 1;
          end;
        end;
      end;
      stad := Stddev(values);
      for x := -1 to 1 do
      begin
        for y := -1 to 1 do
        begin
          if (x <> 0) or (y <> 0) then
          begin
            if MAT[i + x, j + y, 0] >= stad then
            begin
              temp[x + 1, y + 1] := 1;
            end
            else
            begin
              temp[x + 1, y + 1] := 0;
            end;
          end;
        end;
      end;
      for x := -1 to 1 do
      begin
        for y := -1 to 1 do
        begin
          if (x <> 0) or (y <> 0) then
          begin
            if temp[x + 1, y + 1] = 1 then
            begin
              sum := sum + Weights[x + 1, y + 1];
            end;
          end;
        end;
      end;
      AuxMAT[i, j, 0] := sum;
      AuxMAT[i, j, 1] := sum;
      AuxMAT[i, j, 2] := sum;
      MATColor[i, j, 0] := colorscheme[sum, 0];
      MATColor[i, j, 1] := colorscheme[sum, 1];
      MATColor[i, j, 2] := colorscheme[sum, 2];
    end;
  end;
  copMB(ALTO, ANCHO, MATColor, BMAP);
  Form5.Image1.Picture.Assign(BMAP);
end;

procedure TForm1.gradient();
var
  i, j: integer;
  k: byte;
begin
  for i := P1.Y to P2.Y - 2 do
  begin
    for j := P1.X to P2.X - 2 do
    begin
      for k := 0 to 2 do
      begin
        MAT[i, j, k] := Round((0.5) *
          (Abs(MAT[i + 1, j, k] - MAT[i, j, k]) + Abs(MAT[i, j + 1, k] - MAT[i, j, k])));
      end;
    end;
  end;
end;

procedure TForm1.LBPSTDClick(Sender: TObject);
begin
  generatecolscheme();
  escala_de_grises();
  lbpSTDTHRES();
  copMAM(MAT, AuxMAT);
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
  histograma(MAT);
  Form5.ShowModal;
end;

procedure TForm1.lbpMaxValue();
var
  i, j, x, y: integer;
  max, sum: byte;
  MATColor: MATRGB;
  temp: array[0..2, 0..2] of byte;
begin
  copMAM(MATColor, MAT);
  copMAM(AuxMAT, MAT);
  for i := P1.Y + 1 to P2.Y - 2 do
  begin
    for j := P1.X + 1 to P2.X - 2 do
    begin
      max := 0;
      sum := 0;
      for x := -1 to 1 do
      begin
        for y := -1 to 1 do
        begin
          if (x <> 0) or (y <> 0) then
          begin
            if MAT[i + x, j + y, 0] > max then
            begin
              max := MAT[i + x, j + y, 0];
            end;
          end;
        end;
      end;
      for x := -1 to 1 do
      begin
        for y := -1 to 1 do
        begin
          if (x <> 0) or (y <> 0) then
          begin
            if MAT[i + x, j + y, 0] >= max then
            begin
              temp[x + 1, y + 1] := 1;
            end
            else
            begin
              temp[x + 1, y + 1] := 0;
            end;
          end;
        end;
      end;
      for x := -1 to 1 do
      begin
        for y := -1 to 1 do
        begin
          if (x <> 0) or (y <> 0) then
          begin
            if temp[x + 1, y + 1] = 1 then
            begin
              sum := sum + Weights[x + 1, y + 1];
            end;
          end;
        end;
      end;
      AuxMAT[i, j, 0] := sum;
      AuxMAT[i, j, 1] := sum;
      AuxMAT[i, j, 2] := sum;
      MATColor[i, j, 0] := colorscheme[sum, 0];
      MATColor[i, j, 1] := colorscheme[sum, 1];
      MATColor[i, j, 2] := colorscheme[sum, 2];
    end;
  end;
  copMB(ALTO, ANCHO, MATColor, BMAP);
  Form5.Image1.Picture.Assign(BMAP);
end;

procedure TForm1.LBPTHRESHOLDClick(Sender: TObject);
begin
  generatecolscheme();
  escala_de_grises();
  //SetLength(AuxMAT, ALTO, ANCHO, 3);
  lbpMaxValue();
  copMAM(MAT, AuxMAT);
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
  histograma(MAT);
  Form5.ShowModal;
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
      M[i, j, 0] := GetRValue(cl);
      M[i, j, 1] := GetGValue(cl);
      M[i, j, 2] := GetBValue(cl);
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
      M[i, j, 0] := P[k + 2];
      M[i, j, 1] := P[k + 1];
      M[i, j, 2] := P[k];
    end; //j
  end; //i
end;

//procedimiento para copiar de MAtriz a bitmap
procedure tform1.copMB(al, an: integer; M: MATRGB; var B: Tbitmap);
var
  i, j, k: integer;
  P: Pbyte;
begin
  B.Width := an; // Establece el ancho del TBitmap
  B.Height := al; // Establece la altura del TBitmap
  for i := 0 to al - 1 do
  begin
    B.BeginUpdate;
    P := B.ScanLine[i];
    //Invocar método para tener listo en memoria la localidad a modificar--> toda la fila
    B.EndUpdate;
    for j := 0 to an - 1 do
    begin             //asignando valores de matriz al apuntador scanline--> Bitmap
      k := 3 * j;
      P[k + 2] := M[i, j, 0];
      P[k + 1] := M[i, j, 1];
      P[k] := M[i, j, 2];
    end; //j
  end; //i
end;

procedure TForm1.histograma(M: MATRGB);
begin
  Form2.DrawHistogramm(M, ANCHO, ALTO);
  Form2.Show;
end;

end.

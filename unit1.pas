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

  TForm1 = class(TForm)
    ColorDialog1: TColorDialog;
    Image1: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    FiltroGrises: TMenuItem;
    binarizacion: TMenuItem;
    Gamma: TMenuItem;
    Izq: TMenuItem;
    Der: TMenuItem;
    LBP: TMenuItem;
    LBPTHRESHOLD: TMenuItem;
    LBPSTD: TMenuItem;
    Bordes: TMenuItem;
    Patron: TMenuItem;
    SuavizadoArit: TMenuItem;
    ReduxContrast: TMenuItem;
    Reflexion: TMenuItem;
    Rotar: TMenuItem;
    Transformar: TMenuItem;
    Tanhip: TMenuItem;
    Restaurar: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    Abrir_Scanline: TMenuItem;
    FiltroNegativo: TMenuItem;
    MenuItem6: TMenuItem;
    colorxyz: TMenuItem;
    MenuItem8: TMenuItem;
    Histogramaa: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    ScrollBox1: TScrollBox;
    StatusBar1: TStatusBar;
    procedure DerClick(Sender: TObject);
    procedure FiltroGrisesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GammaClick(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure binarizacionClick(Sender: TObject);
    procedure IzqClick(Sender: TObject);
    procedure LBPSTDClick(Sender: TObject);
    procedure LBPTHRESHOLDClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure Abrir_ScanlineClick(Sender: TObject);
    procedure FiltroNegativoClick(Sender: TObject);
    procedure colorxyzClick(Sender: TObject);
    procedure HistogramaaClick(Sender: TObject);
    procedure BordesClick(Sender: TObject);
    procedure PatronClick(Sender: TObject);
    procedure ReduxContrastClick(Sender: TObject);
    procedure ReflexionClick(Sender: TObject);
    procedure RestaurarClick(Sender: TObject);
    procedure SuavizadoAritClick(Sender: TObject);
    procedure TanhipClick(Sender: TObject);
  private
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
  end;

var
  HistR, HistG, HistB: array[0..255] of integer;
  Form1: TForm1;
  ALTO, ANCHO, NewAncho, NewAlto: integer; //dimensiones de la imagen
  MAT, AuxMAT: MATRGB;
  BMAP, BMAP2: Tbitmap;  //objeto orientado a directivas/metodos para .BMP
  pathFile: string;
  counter: shortint = 0;
  grades: double = 0.0;
  colorscheme: array[0..255] of array[0..2] of byte;

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

procedure TForm1.Abrir_ScanlineClick(Sender: TObject);
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

    StatusBar1.Panels[8].Text := IntToStr(ALTO) + 'x' + IntToStr(ANCHO);
    SetLength(MAT, ALTO, ANCHO, 3);
    copBM(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);  //visulaizar imagen
    histograma(MAT);
  end;

end;

procedure TForm1.FiltroNegativoClick(Sender: TObject);
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

procedure TForm1.PatronClick(Sender: TObject);
begin
  pattern();
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
  histograma(MAT);
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
    for i := 0 to ALTO - 1 do
    begin
      for j := 0 to ANCHO - 1 do
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
    for i := 0 to ALTO - 1 do
    begin
      for j := 0 to ANCHO - 1 do
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

procedure TForm1.ReflexionClick(Sender: TObject);
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

procedure TForm1.RestaurarClick(Sender: TObject);
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
end;

procedure TForm1.SuavizadoAritClick(Sender: TObject);
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
  SetLength(AuxMAT, ALTO, ANCHO, 3);
  for i := 1 to ALTO - 2 do
  begin
    for j := 1 to ANCHO - 2 do
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

procedure TForm1.tanhyper(alphaval: double);
var
  i, j: integer;
  k: byte;
  Value: double;
begin
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
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

procedure TForm1.FormCreate(Sender: TObject);
begin
  BMAP := TBitmap.Create;  //crear el objeto BMAP
end;

procedure TForm1.GammaClick(Sender: TObject);
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

procedure TForm1.escala_de_grises();
var
  i, j: integer;
  k: byte;
begin
  //filtro escala de grises, promedio de los valores de los canales R=G=B
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
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
  i := 0;
  while i <= ALTO - 1 do
  begin
    j := 0;
    while j <= ALTO - 1 do
    begin
      sumatoria := 0;
      Rsize := 0;
      for k := i to Min(i + m - 1, ALTO - 1) do
      begin
        for l := j to Min(j + m - 1, ALTO - 1) do
        begin
          sumatoria := sumatoria + MAT[k, l, 0];
          Rsize := Rsize + 1;
        end;
      end;
      threshold := sumatoria div Rsize;
      for k := i to Min(i + m - 1, ALTO - 1) do
      begin
        for l := j to Min(j + m - 1, ALTO - 1) do
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
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
    begin
      for k := 0 to 2 do
      begin
        res := Power((MAT[i, j, k] / 255), gamaval) * 255;
        MAT[i, j, k] := Round(res);
      end;
    end;
  end;
end;

procedure TForm1.FiltroGrisesClick(Sender: TObject);
begin
  escala_de_grises();
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
  histograma(MAT);
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


procedure TForm1.DerClick(Sender: TObject);
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

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  //al mover el mouse, indica las coordenadas X Y

  StatusBar1.Panels[1].Text := IntToStr(X);
  StatusBar1.Panels[2].Text := IntToStr(Y);
  StatusBar1.Panels[4].Text := IntToStr(MAT[y, x, 0]);
  StatusBar1.Panels[5].Text := IntToStr(MAT[y, x, 1]);
  StatusBar1.Panels[6].Text := IntToStr(MAT[y, x, 2]);

end;

procedure TForm1.binarizacionClick(Sender: TObject);
begin
  if ALTO = ANCHO then
  begin
    Form3.TrackBar1.Min := 3;
    Form3.TrackBar1.Max := ALTO;
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

procedure TForm1.IzqClick(Sender: TObject);
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

procedure TForm1.lbpSTDTHRES();
var
  i, j, x, y: integer;
  max, sum, k: byte;
  stad: double;
  MATColor: MATRGB;
  values: array[0..7] of double;
  temp: array[0..2, 0..2] of byte;
begin
  SetLength(MATColor, ALTO, ANCHO, 3);
  for i := 1 to ALTO - 2 do
  begin
    for j := 1 to ANCHO - 2 do
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
  for i := 0 to ALTO - 2 do
  begin
    for j := 0 to ANCHO - 2 do
    begin
      for k := 0 to 2 do
      begin
        MAT[i, j, k] := Round(
          (0.5) * (Abs(MAT[i + 1, j, k] - MAT[i, j, k]) +
          Abs(MAT[i, j + 1, k] - MAT[i, j, k])));
      end;
    end;
  end;
end;

procedure TForm1.LBPSTDClick(Sender: TObject);
begin
  generatecolscheme();
  escala_de_grises();
  SetLength(AuxMAT, ALTO, ANCHO, 3);
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
  SetLength(MATColor, ALTO, ANCHO, 3);
  for i := 1 to ALTO - 2 do
  begin
    for j := 1 to ANCHO - 2 do
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
  SetLength(AuxMAT, ALTO, ANCHO, 3);
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

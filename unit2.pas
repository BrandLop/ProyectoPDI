unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, TAGraph,
  TASeries, TASources, TACustomSource, TATransformations;

type

  { TForm2 }
  MATRGB = array of array of array of byte;

  TForm2 = class(TForm)
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    Chart1LineSeries2: TLineSeries;
    Chart1LineSeries3: TLineSeries;
    StatusBar1: TStatusBar;
    procedure Chart1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure Chart1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    //function ListChartSource1Compare(AItem1, AItem2: Pointer): Integer;
  private
    valNorm: integer;

  public
    nminval, nmaxval, resp: integer;
    procedure DrawHistogramm(mat: MATRGB; w, h: integer);

  end;

var
  Form2: TForm2;
  ClickEnabled: boolean = False;
  counter: byte = 0;

implementation

{$R *.lfm}

procedure TForm2.Chart1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
const
  min = 9;
  max = 580;
  new_min = 0;
  new_max = 255;
begin
  valNorm := Round((X - min) / (max - min) * (new_max - new_min) + new_min);
  StatusBar1.Panels[1].Text := IntToStr(valNorm);
end;

procedure TForm2.Chart1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  if ClickEnabled then
  begin
    if Button = mbLeft then
    begin
      counter := counter + 1;
      nminval := valNorm;
      ShowMessage('Nuevo valor minimo: ' + IntToStr(nminval));
    end;
    if Button = mbRight then
    begin
      counter := counter + 1;
      nmaxval := valNorm;
      ShowMessage('Nuevo valor máximo: ' + IntToStr(nmaxval));
    end;
    if counter = 2 then
    begin
      resp := MessageDlg(
        '¿Desea realizar la reducción de contraste con los valores seleccionados?', mtConfirmation, mbOKCancel, 0);
      counter := 0;
      Self.Close;
    end;
  end;

end;

procedure TForm2.DrawHistogramm(mat: MATRGB; w, h: integer);
var
  i, j, area: integer;
  r, g, b: byte;
  histR, histG, histB: array[0..255] of integer;
begin
  //Chart1.ScaleBy(150,100);
  Chart1LineSeries1.Clear;
  Chart1LineSeries2.Clear;
  Chart1LineSeries3.Clear;

  FillChar(histR, SizeOf(histR), 0);
  FillChar(histG, SizeOf(histG), 0);
  FillChar(histB, SizeOf(histB), 0);

  area := w * h;

  for i := 0 to h - 1 do
  begin
    for j := 0 to w - 1 do
    begin
      r := mat[i, j, 0];
      g := mat[i, j, 1];
      b := mat[i, j, 2];

      Inc(histR[r]);
      Inc(histG[g]);
      Inc(histB[b]);
    end;
  end;

  for i := 0 to 255 do
  begin
    Chart1LineSeries1.AddXY(i, histR[i]);
    Chart1LineSeries2.AddXY(i, histG[i]);
    Chart1LineSeries3.AddXY(i, histB[i]);
  end;
end;

end.

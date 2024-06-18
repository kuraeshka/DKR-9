unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons, Edit,
  Grids, StdCtrls;

type

  { TfMain }

  TfMain = class(TForm)
    bAdd: TButton;
    bEdit: TButton;
    bDel: TButton;
    bSort: TButton;
    Panel1: TPanel;
    SG: TStringGrid;
    procedure bAddClick(Sender: TObject);
    procedure bDelClick(Sender: TObject);
    procedure bEditClick(Sender: TObject);
    procedure bSortClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

  type
  Contacts = record
    Name: string[100];
    Telephon: string[20];
    Note: string[20];
    Stoimosti: real;
    Materia: double;
  end; //record

var
  fMain: TfMain;
  adres: string; //адрес, откуда запущена программа
implementation

{$R *.lfm}

{ TfMain }

procedure TfMain.bAddClick(Sender: TObject);
begin
  //очищаем поля, если там что-то есть:
  fEdit.eName.Text:= '';
  fEdit.eTelephone.Text:= '';
  //устанавливаем ModalResult редактора в mrNone:
  fEdit.ModalResult:= mrNone;
  //теперь выводим форму:
  fEdit.ShowModal;
  //если пользователь ничего не ввел - выходим:
  if (fEdit.eName.Text= '') or (fEdit.eTelephone.Text= '') then exit;
  //если пользователь не нажал "Сохранить" - выходим:
  if fEdit.ModalResult <> mrOk then exit;
  //иначе добавляем в сетку строку, и заполняем её:
  SG.RowCount:= SG.RowCount + 1;
  SG.Cells[0, SG.RowCount-1]:= fEdit.eName.Text;
  SG.Cells[1, SG.RowCount-1]:= fEdit.eTelephone.Text;
  SG.Cells[2, SG.RowCount-1]:= fEdit.CBNote.Text;
  SG.Cells[3, SG.RowCount-1]:= fEdit.bmaterrial.Text;
  SG.Cells[4, SG.RowCount-1]:= fEdit.bstoimosti.Text;
end;

procedure TfMain.bDelClick(Sender: TObject);
begin
  //если данных нет - выходим:
  if SG.RowCount = 1 then exit;
  //иначе выводим запрос на подтверждение:
  if MessageDlg('Требуется подтверждение',
                'Вы действительно хотите удалить контакт "' +
                SG.Cells[0, SG.Row] + '"?',
      mtConfirmation, [mbYes, mbNo, mbIgnore], 0) = mrYes then
         SG.DeleteRow(SG.Row);
end;


procedure TfMain.bEditClick(Sender: TObject);
begin
  //если данных в сетке нет - просто выходим:
  if SG.RowCount = 1 then exit;
  //иначе записываем данные в форму редактора:
  fEdit.eName.Text:= SG.Cells[0, SG.Row];
  fEdit.eTelephone.Text:= SG.Cells[1, SG.Row];
  fEdit.CBNote.Text:= SG.Cells[2, SG.Row];
  fEdit.bmaterrial.Text:= SG.Cells[3, SG.Row];
  fEdit.bstoimosti.Text:= SG.Cells[4, SG.ROW];
  //устанавливаем ModalResult редактора в mrNone:
  fEdit.ModalResult:= mrNone;
  //теперь выводим форму:
  fEdit.ShowModal;
  //сохраняем в сетку возможные изменения,
  //если пользователь нажал "Сохранить":
  if fEdit.ModalResult = mrOk then begin
    SG.Cells[0, SG.Row]:= fEdit.eName.Text;
    SG.Cells[1, SG.Row]:= fEdit.eTelephone.Text;
    SG.Cells[2, SG.Row]:= fEdit.CBNote.Text;
    SG.Cells[3, SG.Row]:= fEdit.bmaterrial.Text;
    SG.Cells[4, SG.Row]:= fEdit.bstoimosti.Text;
  end;
end;

procedure TfMain.bSortClick(Sender: TObject);
begin
  //если данных в сетке нет - просто выходим:
  if SG.RowCount = 1 then exit;
  //иначе сортируем список:
  SG.SortColRow(true, 0);
end;

procedure TfMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  MyCont: Contacts; //для очередной записи
  f: file of Contacts; //файл данных
  i: integer; //счетчик цикла
begin
  //если строки данных пусты, просто выходим:
  if SG.RowCount = 1 then exit;
  //иначе открываем файл для записи:
  try
    AssignFile(f, adres + 'telephones.dat');
    Rewrite(f);
    //теперь цикл - от первой до последней записи сетки:
    for i:= 1 to SG.RowCount-1 do begin
      //получаем данные текущей записи:
      MyCont.Name:= SG.Cells[0, i];
      MyCont.Telephon:= SG.Cells[1, i];
      MyCont.Note:= SG.Cells[2, i];
      MyCont.Materia:= StrToFloat(SG.Cells[3, i]);
      MyCont.Stoimosti:= StrToFloat(SG.Cells[4, i]);
      //записываем их:
      Write(f, MyCont);
    end;
  finally
    CloseFile(f);
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
var
  MyCont: Contacts; //для очередной записи
  f: file of Contacts; //файл данных
  i: integer; //счетчик цикла
begin
  //сначала получим адрес программы:
  adres:= ExtractFilePath(ParamStr(0));
  //настроим сетку:
  SG.Cells[0, 0]:= 'Модель';
  SG.Cells[1, 0]:= 'Фирма';
  SG.Cells[2, 0]:= 'Тип';
  SG.Cells[3, 0]:= 'Материал';
  SG.Cells[4, 0]:= 'Стоимость';
  SG.ColWidths[0]:= 150;
  SG.ColWidths[1]:= 150;
  SG.ColWidths[2]:= 150;
  SG.ColWidths[3]:= 150;
  SG.ColWidths[4]:= 150;
  //если файла данных нет, просто выходим:
  if not FileExists(adres + 'telephones.dat') then exit;
  //иначе файл есть, открываем его для чтения и
  //считываем данные в сетку:
  try
    AssignFile(f, adres + 'telephones.dat');
    Reset(f);
    //теперь цикл - от первой до последней записи сетки:
    while not Eof(f) do begin
      //считываем новую запись:
      Read(f, MyCont);
      //добавляем в сетку новую строку, и заполняем её:
        SG.RowCount:= SG.RowCount + 1;
        SG.Cells[0, SG.RowCount-1]:= MyCont.Name;
        SG.Cells[1, SG.RowCount-1]:= MyCont.Telephon;
        SG.Cells[2, SG.RowCount-1]:= MyCont.Note;
        SG.Cells[3, SG.RowCount-1]:= FloatToStr(MyCont.Materia);
        SG.Cells[4, SG.RowCount-1]:= FloatToStr(MyCont.Stoimosti);
    end;
  finally
    CloseFile(f);
  end;
end;




end.


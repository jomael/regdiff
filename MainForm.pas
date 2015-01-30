{                                                                             }
{  Copyright (C) 2007 Miguel E. Hernández Cuervo                              }
{                                                                             }
{ Licensed under the Apache License, Version 2.0 (the "License");             }
{ you may not use this file except in compliance with the License.            }
{ You may obtain a copy of the License at                                     }
{                                                                             }
{      http://www.apache.org/licenses/LICENSE-2.0                             }
{                                                                             }
{ Unless required by applicable law or agreed to in writing, software         }
{ distributed under the License is distributed on an "AS IS" BASIS,           }
{ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{ See the License for the specific language governing permissions and         }
{ limitations under the License.                                              }
{                                                                             }


unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan, ShellApi, RegistryTree;

const
  ProgramName         = 'RegDiff';
  ProgramDescription  = 'Find the differences between two Windows registry states';

type
  TForm1 = class(TForm)
    Button1     : TButton;
    Button3     : TButton;
    Memo1       : TMemo;
    Button5     : TButton;
    Timer1      : TTimer;
    XPManifest1 : TXPManifest;
    SaveDialog1 : TSaveDialog;
    Button4: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    LMRoot        : RegistryRoot;
    URoot         : RegistryRoot;

    {Roots manipulation}
    procedure CreateRoots;
    procedure ClearRoots;
    procedure DisposeRoots;

    {Registry manipulation}
    procedure ShotRegistry(First : ByteBool);
    procedure SaveRegistry(FileName : String);
    procedure Compare;
    procedure SaveCompare(FileName : String);
  public
    { Public declarations }
  end;

var
  {Global stuff}
  Form1     : TForm1;

implementation

uses StrUtils;

{$R *.dfm}

procedure TForm1.CreateRoots;
begin
  LMRoot := RegistryRoot.Create(HKEY_LOCAL_MACHINE);
  URoot := RegistryRoot.Create(HKEY_USERS);
end;

procedure TForm1.ClearRoots;
begin
  LMRoot.Clear;
  URoot.Clear;
end;

procedure TForm1.DisposeRoots;
begin
  LMRoot.Delete;
  URoot.Delete;
end;

{Load registry into memory}
procedure TForm1.ShotRegistry(First : ByteBool);
begin
  Memo1.Lines.Add('  HKEY_LOCAL_MACHINE...');
  if First then
    LMRoot.Shot1
  else
    LMRoot.Shot2;

  Memo1.Lines.Add('  HKEY_USERS...');
  if First then
    URoot.Shot1
  else
    URoot.Shot2;
end;

{Save registry to a file}
procedure TForm1.SaveRegistry(FileName : String);
var
  OutFile : TextFile;
begin
  AssignFile(OutFile, FileName);
  Rewrite(OutFile);
  Writeln(OutFile, '-------------------------');
  Writeln(OutFile, '  TOTAL ITEMS: ', LMRoot.KeyCount + LMRoot.ValueCount + URoot.KeyCount + URoot.ValueCount);
  Writeln(OutFile, '-------------------------');
  Writeln(OutFile, '-------------------------');
  Writeln(OutFile, '  KEYS      Total: ', LMRoot.KeyCount + URoot.KeyCount);
  Writeln(OutFile, '-------------------------');
  LMRoot.WriteKeysToFile(OutFile);
  URoot.WriteKeysToFile(OutFile);
  Writeln(OutFile, '-------------------------');
  Writeln(OutFile, '  VALUES    Total: ', LMRoot.ValueCount + URoot.ValueCount);
  Writeln(OutFile, '-------------------------');
  LMRoot.WriteValuesToFile(OutFile);
  URoot.WriteValuesToFile(OutFile);
  CloseFile(OutFile);
end;

{Compare reistry}
procedure TForm1.Compare;
begin
  Memo1.Lines.Add('[Comparing...]');
  LMRoot.Compare;
  URoot.Compare;
  Memo1.Lines.Add('[Done]');
end;

{Save differences to a file}
procedure TForm1.SaveCompare(FileName : String);
var
  OutFile : TextFile;
begin
  AssignFile(OutFile, FileName);
  Rewrite(OutFile); {Check for IO exception}

  Writeln(OutFile, ' ______________________________');
  Writeln(OutFile, '|  REGISTRY CHANGES            |');
  Writeln(OutFile, ' ______________________________');
  Writeln(OutFile, '');
  Writeln(OutFile, '');

  Writeln(OutFile, '--[Added keys]----------------');
  LMRoot.WriteCreatedKeysToFile(OutFile);
  URoot.WriteCreatedKeysToFile(OutFile);
  Writeln(OutFile, '------------------------------');
  Writeln(OutFile, '');
  Writeln(OutFile, '');

  Writeln(OutFile, '--[Added values]--------------');
  LMRoot.WriteCreatedValuesToFile(OutFile);
  URoot.WriteCreatedValuesToFile(OutFile);
  Writeln(OutFile, '------------------------------');
  Writeln(OutFile, '');
  Writeln(OutFile, '');

  Writeln(OutFile, '--[Modified values]-----------');
  LMRoot.WriteModifiedValuesToFile(OutFile);
  URoot.WriteModifiedValuesToFile(OutFile);
  Writeln(OutFile, '------------------------------');
  Writeln(OutFile, '');
  Writeln(OutFile, '');

  Writeln(OutFile, '--[Deleted keys]--------------');
  LMRoot.WriteDeletedKeysToFile(OutFile);
  URoot.WriteDeletedKeysToFile(OutFile);
  Writeln(OutFile, '------------------------------');
  Writeln(OutFile, '');
  Writeln(OutFile, '');

  Writeln(OutFile, '--[Deleted values]------------');
  LMRoot.WriteDeletedValuesToFile(OutFile);
  URoot.WriteDeletedValuesToFile(OutFile);
  Writeln(OutFile, '------------------------------');

  CloseFile(OutFile);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  dt2  : TDateTime;
begin

  Memo1.Lines.Add('[Taking snapshot 1...]');
  ShotRegistry(True);
  dt2 := Time();
  Memo1.Lines.Add('[Done at ' + TimeToStr(dt2) + ']');

  Button3.Enabled := True;
  Button5.Enabled := True;
  Label3.Caption := IntToStr(LMRoot.KeyCount + URoot.KeyCount);
  Label4.Caption := IntToStr(LMRoot.ValueCount + URoot.ValueCount);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  ClearRoots;
  Button3.Enabled := False;
  Button4.Enabled := False;
  Button5.Enabled := False;
  Label3.Caption  := '';
  Label4.Caption  := '';
  Memo1.Clear;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  dt2 : TDateTime;
begin
  Memo1.Lines.Add('[Taking snapshot 2...]');
  ShotRegistry(False);
  dt2 := Time();
  Memo1.Lines.Add('[Done at ' + TimeToStr(dt2) + ']');
  Button4.Enabled := True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if (SaveDialog1.Execute) then
  begin
    SaveRegistry(SaveDialog1.FileName);
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  FileName : String;
  Handle   : HWND;
begin
  Handle := 0;
  Compare;

  {
  dt := Date;
  FileName := DateToStr(dt);
  dt := Time;
  FileName := FileName + ' - ' + TimeToStr(dt) + '.txt';
  FileName := AnsiReplaceStr(FileName, ':', '-');
  FileName := AnsiReplaceStr(FileName, '/', '-');
  }

  FileName := 'results.txt';
  SaveCompare(FileName);
  ShellExecute(Handle, 'open', PChar(FileName), nil, nil, SW_SHOWNORMAL);
  Button3.Enabled := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  Rec: LongRec;
  AppVersionStr: string;
begin
  Rec := LongRec(GetFileVersion(ParamStr(0)));
  AppVersionStr := Format('%d.%d', [Rec.Hi, Rec.Lo]);
  Caption := ProgramName + ' v' + AppVersionStr;
  CreateRoots;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  DisposeRoots;
end;

end.

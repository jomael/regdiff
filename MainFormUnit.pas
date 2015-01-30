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


unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, XPMan, ShellApi, RegistryTree, ToolWin,
  ComCtrls;

const
  ProgramName         = 'RegDiff';
  ProgramDescription  = 'Find the differences between two Windows Registry states';

type
  TMainForm = class(TForm)
    Shot1Button: TButton;
    Shot2Button: TButton;
    Memo: TMemo;
    ClearButton: TButton;
    Timer: TTimer;
    XPManifest: TXPManifest;
    SaveDialog: TSaveDialog;
    ShowResultsButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    HelpButton: TButton;
    procedure Shot1ButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure Shot2ButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ShowResultsButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
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
  MainForm     : TMainForm;

implementation

uses StrUtils;

{$R *.dfm}

procedure TMainForm.CreateRoots;
begin
  LMRoot := RegistryRoot.Create(HKEY_LOCAL_MACHINE);
  URoot := RegistryRoot.Create(HKEY_USERS);
end;

procedure TMainForm.ClearRoots;
begin
  LMRoot.Clear;
  URoot.Clear;
end;

procedure TMainForm.DisposeRoots;
begin
  LMRoot.Delete;
  URoot.Delete;
end;

{Load registry into memory}
procedure TMainForm.ShotRegistry(First : ByteBool);
begin
  Memo.Lines.Add('  HKEY_LOCAL_MACHINE...');
  if First then
    LMRoot.Shot1
  else
    LMRoot.Shot2;

  Memo.Lines.Add('  HKEY_USERS...');
  if First then
    URoot.Shot1
  else
    URoot.Shot2;
end;

{Save registry to a file}
procedure TMainForm.SaveRegistry(FileName : String);
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
procedure TMainForm.Compare;
begin
  Memo.Lines.Add('[Comparing...]');
  LMRoot.Compare;
  URoot.Compare;
  Memo.Lines.Add('[Done]');
end;

{Save differences to a file}
procedure TMainForm.SaveCompare(FileName : String);
var
  OutFile : TextFile;
begin
  AssignFile(OutFile, FileName);
  Rewrite(OutFile); {Check for IO exception}

  Writeln(OutFile, ' ______________________________');
  Writeln(OutFile, '|          CHANGES            |');
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

procedure TMainForm.Shot1ButtonClick(Sender: TObject);
var
  dt2  : TDateTime;
begin
  Memo.Lines.Add('[Taking first snapshot...]');
  ShotRegistry(True);
  dt2 := Time();
  Memo.Lines.Add('[Done at ' + TimeToStr(dt2) + ']');
  Shot2Button.Enabled := True;
  ClearButton.Enabled := True;
  Label3.Caption := IntToStr(LMRoot.KeyCount + URoot.KeyCount);
  Label4.Caption := IntToStr(LMRoot.ValueCount + URoot.ValueCount);
end;

procedure TMainForm.ClearButtonClick(Sender: TObject);
begin
  ClearRoots;
  Shot2Button.Enabled := False;
  ClearButton.Enabled := False;
  ShowResultsButton.Enabled := False;
  Label3.Caption  := '';
  Label4.Caption  := '';
  Memo.Clear;
end;

procedure TMainForm.Shot2ButtonClick(Sender: TObject);
var
  dt2 : TDateTime;
begin
  Memo.Lines.Add('[Taking second snapshot...]');
  ShotRegistry(False);
  dt2 := Time();
  Memo.Lines.Add('[Done at ' + TimeToStr(dt2) + ']');
  ShowResultsButton.Enabled := True;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  if (SaveDialog.Execute) then
  begin
    SaveRegistry(SaveDialog.FileName);
  end;
end;

procedure TMainForm.ShowResultsButtonClick(Sender: TObject);
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
  // Button3.Enabled := False;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Rec: LongRec;
  AppVersionStr: string;
begin
  Rec := LongRec(GetFileVersion(ParamStr(0)));
  AppVersionStr := Format('%d.%d', [Rec.Hi, Rec.Lo]);
  Caption := ProgramName + ' v' + AppVersionStr;
  CreateRoots;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DisposeRoots;
end;

procedure TMainForm.HelpButtonClick(Sender: TObject);
begin
ShowMessage(ProgramDescription + #13#10);
end;

end.

program RegDiff;

uses
  Forms,
  MainFormUnit in 'MainFormUnit.pas' {MainForm},
  RegistryTree in 'RegistryTree.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'RegDiff';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

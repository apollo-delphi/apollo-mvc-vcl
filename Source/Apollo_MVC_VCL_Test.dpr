program Apollo_MVC_VCL_Test;

{$STRONGLINKTYPES ON}
uses
  Vcl.Forms,
  System.SysUtils,
  DUnitX.Loggers.GUI.VCL,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  tst_Apollo_MVC_VCL in 'tst_Apollo_MVC_VCL.pas',
  Apollo_MVC_VCL in 'Apollo_MVC_VCL.pas' {ViewVCLBase};

begin
  Application.Initialize;
  Application.Title := 'DUnitX';
  Application.CreateForm(TGUIVCLTestRunner, GUIVCLTestRunner);
  Application.CreateForm(TViewVCLBase, ViewVCLBase);
  Application.Run;
end.

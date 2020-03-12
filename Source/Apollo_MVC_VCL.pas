unit Apollo_MVC_VCL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Apollo_MVC_Core;

type
  TViewVCLBase = class abstract(TForm)
  private
    { Private declarations }
    FView: TView;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.

unit Apollo_MVC_VCL;

interface

uses
  Apollo_MVC_Core,
  System.Classes,
  System.SysUtils,
  System.Variants,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Graphics,
  Winapi.Messages,
  Winapi.Windows;

type
  TViewVCLBase = class abstract(TForm, IViewBase)
  private
    FViewBase: IViewBase;
    function GetViewBase: IViewBase;
    property BaseView: IViewBase read GetViewBase implements IViewBase;
  protected
    procedure DoClose(var Action: TCloseAction); override;
    procedure FireEvent(const aEventName: string);
    procedure Remember(const aPropName: string; const aValue: Variant);
  public
  end;

  TViewVCLMain = class abstract(TViewVCLBase)
  protected
    procedure LinkToController(out aController: TControllerAbstract); virtual; abstract;
  public
    constructor Create(aOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

{ TViewVCLBase }

procedure TViewVCLBase.DoClose(var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  inherited;

  FireEvent(mvcViewClose);
end;

procedure TViewVCLBase.FireEvent(const aEventName: string);
begin
  BaseView.FireEvent(aEventName);
end;

function TViewVCLBase.GetViewBase: IViewBase;
begin
  if not Assigned(FViewBase) then
    FViewBase := MakeViewBase(Self);
  Result := FViewBase;
end;

procedure TViewVCLBase.Remember(const aPropName: string; const aValue: Variant);
begin
  BaseView.Remember(aPropName, aValue);
end;

{ TViewVCLMain }

constructor TViewVCLMain.Create(aOwner: TComponent);
var
  Controller: TControllerAbstract;
begin
  inherited;

  try
    LinkToController(Controller);
  except
    on E: EAbstractError do
      raise Exception.CreateFmt('MVC_VCL: %s should override LinkToController virtual procedure', [ClassName]);
  else
    raise;
  end;

  Controller.RegisterView(Self);
end;

end.

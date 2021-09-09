unit Apollo_MVC_VCL;

interface

uses
  Apollo_MVC_Core,
  FireDAC.VCLUI.Wait,
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
    property ViewBase: IViewBase read GetViewBase implements IViewBase;
  protected
    procedure DoClose(var Action: TCloseAction); override;
    procedure FireEvent(const aEventName: string);
    procedure Init; virtual;
    procedure Recover(const aPropName: string; aValue: string); virtual;
    procedure Remember(const aPropName: string; const aValue: Variant);
  public
    constructor Create(aOwner: TComponent); override;
  end;

  TViewVCLMain = class abstract(TViewVCLBase)
  protected
    procedure LinkToController(out aController: TControllerAbstract); virtual; abstract;
  public
    constructor Create(aOwner: TComponent); override;
  end;

  TFrameHelper = class helper for TFrame
  protected
    procedure FireEvent(aViewBase: IViewBase; const aEventName: string);
  end;

implementation

{$R *.dfm}

{ TViewVCLBase }

constructor TViewVCLBase.Create(aOwner: TComponent);
begin
  Init;

  inherited;
end;

procedure TViewVCLBase.DoClose(var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  inherited;

  FireEvent(mvcViewClose);
end;

procedure TViewVCLBase.FireEvent(const aEventName: string);
begin
  ViewBase.FireEvent(aEventName);
end;

function TViewVCLBase.GetViewBase: IViewBase;
begin
  if not Assigned(FViewBase) then
  begin
    FViewBase := MakeViewBase(Self);
    FViewBase.OnRecover := Recover;
  end;
  Result := FViewBase;
end;

procedure TViewVCLBase.Init;
begin
end;

procedure TViewVCLBase.Recover(const aPropName: string; aValue: string);
begin
end;

procedure TViewVCLBase.Remember(const aPropName: string; const aValue: Variant);
begin
  ViewBase.Remember(aPropName, aValue);
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
      raise Exception.CreateFmt('MVC_VCL: %s must override LinkToController virtual procedure.', [ClassName]);
  else
    raise;
  end;

  Controller.RegisterView(Self);
end;

{ TFrameHelper }

procedure TFrameHelper.FireEvent(aViewBase: IViewBase; const aEventName: string);
begin
  if not Owner.InheritsFrom(TViewVCLBase) then
    raise Exception.Create('TFrameHelper.GetViewBase: Owner of TFrame must inherits from TViewVCLBase.');

  if not Assigned(aViewBase) then
  begin
    aViewBase := MakeViewBase(Self);
    aViewBase.EventProc := TViewVCLBase(Owner).ViewBase.EventProc;
  end;

  aViewBase.FireEvent(aEventName);
end;

end.

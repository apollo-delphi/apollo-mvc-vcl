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
  protected
    function EncodeNumProp(const aKey: string; const aNum: Integer): string;
    function TryGetNumProp(const aPropName, aKey: string; out aNum: Integer): Boolean;
    procedure DoClose(var Action: TCloseAction); override;
    procedure FireEvent(const aEventName: string);
    procedure InitControls; virtual;
    procedure InitVariables; virtual;
    procedure Recover(const aPropName: string; aValue: Variant); virtual;
    procedure Remember(const aPropName: string; const aValue: Variant);
    procedure ValidateControls; virtual;
    property ViewBase: IViewBase read GetViewBase implements IViewBase;
  end;

  TViewVCLMain = class abstract(TViewVCLBase)
  protected
    procedure LinkToController(out aController: TControllerAbstract); virtual; abstract;
  public
    constructor Create(aOwner: TComponent); override;
  end;

  TFrameHelper = class helper for TFrame
  protected
    function GetOwnerViewBase: IViewBase;
    procedure FireEvent(var aViewBase: IViewBase; const aEventName: string);
  end;

implementation

{$R *.dfm}

{ TViewVCLBase }

procedure TViewVCLBase.DoClose(var Action: TCloseAction);
begin
  if ModalResult = mrOK then
    ValidateControls;
  Action := TCloseAction.caFree;
  inherited;

  FireEvent(mvcViewClose);
end;

function TViewVCLBase.EncodeNumProp(const aKey: string;
  const aNum: Integer): string;
begin
  Result := FViewBase.EncodeNumProp(aKey, aNum);
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
    FViewBase.OnInitControls := InitControls;
    FViewBase.OnInitVariables := InitVariables;
  end;
  Result := FViewBase;
end;

procedure TViewVCLBase.InitControls;
begin
end;

procedure TViewVCLBase.InitVariables;
begin
end;

procedure TViewVCLBase.Recover(const aPropName: string; aValue: Variant);
begin
end;

procedure TViewVCLBase.Remember(const aPropName: string; const aValue: Variant);
begin
  ViewBase.Remember(aPropName, aValue);
end;

function TViewVCLBase.TryGetNumProp(const aPropName, aKey: string;
  out aNum: Integer): Boolean;
begin
  Result := ViewBase.TryGetNumProp(aPropName, aKey, aNum);
end;

procedure TViewVCLBase.ValidateControls;
begin
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

procedure TFrameHelper.FireEvent(var aViewBase: IViewBase; const aEventName: string);
begin
  if not Owner.InheritsFrom(TViewVCLBase) then
    raise Exception.Create('TFrameHelper.GetViewBase: Owner of TFrame must inherits from TViewVCLBase.');

  if not Assigned(aViewBase) then
  begin
    aViewBase := MakeViewBase(Self);
    aViewBase.EventProc := GetOwnerViewBase.EventProc;
  end;

  aViewBase.FireEvent(aEventName);
end;

function TFrameHelper.GetOwnerViewBase: IViewBase;
begin
  if not Owner.InheritsFrom(TViewVCLBase) then
    raise Exception.Create('TFrameHelper.GetViewBase: Owner of TFrame must inherits from TViewVCLBase.');

  Result := TViewVCLBase(Owner).ViewBase;
end;

end.

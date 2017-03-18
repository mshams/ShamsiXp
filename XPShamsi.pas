{
License:
GNU Public License (GPL3) [http://www.gnu.org/licenses/gpl-3.0.txt]

Project:	Shamsi XP
Version:	0.25
Date:		September 23 2009
Author:	Mohammad Shams Javi

Shamsi XP is free software; you can redistribute it and/or modify 
it under the terms of the GNU Lesser General Public License as published 
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version. 
Shamsi XP is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Shamsi XP; if not, see <http://www.gnu.org/copyleft/lesser.html>.

Contact Details:
 Any comments? contact me please.
 E-mail:  M.Shams.J@gmail.com 
 Website: http://www.mshams.ir
 Copyright(C) 2009 Mohammad Shams Javi

Change History:
Date         Author       Description
------------------------------------------
[0.25		mshams.ir]
User defined date format added.
}
unit XPShamsi;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls,
  StdCtrls, messages, ShlObj, ActiveX, ComObj, registry;

type
  TXpShamsiMain = class(TForm)
    sLabel3: TLabel;
    sBtnInstall: TButton;
    sBtnUninstall: TButton;
    sPanel2: TPanel;
    img: TImage;
    sLabel1: TLabel;
    sPanel1: TPanel;
    sLabel2: TLabel;
    sLabel6: TLabel;
    lnk: TLabel;
    grpFormat: TGroupBox;
    cmbFormat: TComboBox;
    cmbSep: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Image1: TImage;
    procedure sBtnInstallClick(Sender: TObject);
    procedure sBtnUninstallClick(Sender: TObject);
    procedure install;
    procedure setdate;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure lnkMouseLeave(Sender: TObject);
    procedure lnkMouseEnter(Sender: TObject);
    procedure lnkClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ShowFormat;
    procedure grpFormatMouseEnter(Sender: TObject);
    procedure grpFormatMouseLeave(Sender: TObject);
    procedure grpFormatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  XpShamsiMain: TXpShamsiMain;
  HLib: Thandle;

  isHooked: boolean = false;


const
  exc: string= 'Shamsi_XP.exe';
  Path='Control Panel\International';

//You can use dynamic declaration also [loadlibrary]
  procedure InstallClockHook; stdcall; external 'clockdriver.DLL';
  procedure UninstallClockHook; stdcall; external 'clockdriver.DLL';

implementation

{$R *.dfm}

function GetWindowsDir:string;
var Buf:array[0..MAX_PATH]of Char;
begin
GetWindowsDirectory(@Buf[0],MAX_PATH+1); Result:=PChar(@Buf[0])+'\';
end;

Function StartupFolder:String;
var   MyReg : TRegIniFile;
begin
MyReg:= TRegIniFile.Create('Software\MicroSoft\Windows\CurrentVersion\Explorer');
result:= MyReg.ReadString('Shell Folders','Startup','');
MyReg.Free;
end;

Function ShortCut_Create(Path, Param, ShortCut_Name:String):Boolean;
Var
  MyObject : IUnknown;
  MySLink : IShellLink;
  MyPFile : IPersistFile;
  FileName : String;
  WFileName : WideString;
Begin

MyObject:= CreateComObject(CLSID_ShellLink);
MySLink:= MyObject as IShellLink;
MyPFile:= MyObject as IPersistFile;
FileName:= Path;

MySLink.SetPath(PChar(FileName));
MySLink.SetDescription('http://www.mshams.ir');
MySLink.SetArguments(pchar(param));
MySLink.SetWorkingDirectory(PChar(ExtractFilePath(FileName)));

WFileName:= StartupFolder + '\' + ShortCut_Name + '.lnk';
MyPFile.Save(PWChar(WFileName),False);
result:=True;
End;

procedure TXpShamsiMain.setdate;
begin
if isHooked then exit;
InstallClockHook;
isHooked:= true;
end;

procedure TXpShamsiMain.ShowFormat;
begin
if XpShamsiMain.Height<=244 then
  begin
  XpShamsiMain.Height:= 391;
  grpFormat.Height:= 164;
  sLabel3.Top:= 338;
  lnk.Top:= 338;
  sPanel2.Top:= 327;
  end
else
  begin
  XpShamsiMain.Height:= 244;
  grpFormat.Height:= 20;
  sLabel3.Top:= 193;
  lnk.Top:= 193;
  sPanel2.Top:= 182;
  end;
end;

procedure unsetdate;
begin
if not isHooked then exit;
isHooked := false;
UninstallClockHook;
end;

procedure uninstal;
begin
DeleteFile(StartupFolder + '\' + exc + '.lnk');
end;

procedure TXpShamsiMain.FormActivate(Sender: TObject);
begin
XpShamsiMain.Visible:= true
end;

procedure TXpShamsiMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
XpShamsiMain.Visible:= true;
SendToBack;
XpShamsiMain.Hide;
if isHooked then
  begin
  Action:= caNone;
  end;
end;

procedure TXpShamsiMain.FormCreate(Sender: TObject);
Var s: String;
    MyReg : TRegIniFile;
begin
//Read format setting
MyReg := TRegIniFile.Create('Control Panel');
Try
  MyReg.RootKey:= HKEY_CURRENT_USER;
  s := MyReg.ReadString('International','OptionalFormat','');
  if length(s)>2 then
    begin
    cmbSep.Text:= s[length(s)];
    Delete(s, length(s), 1);
    cmbFormat.Text:= s;
    end;
Finally
  MyReg.Free;
end;
end;

procedure TXpShamsiMain.FormShow(Sender: TObject);
begin
//A tricky way to proof the bug of CodeGear07 in MainFormOnTaskbar=false
ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TXpShamsiMain.grpFormatClick(Sender: TObject);
begin
ShowFormat;
end;

procedure TXpShamsiMain.grpFormatMouseEnter(Sender: TObject);
begin
grpFormat.Font.Style:= [fsUnderline,fsBold];
end;

procedure TXpShamsiMain.grpFormatMouseLeave(Sender: TObject);
begin
grpFormat.Font.Style:= [];
end;

procedure TXpShamsiMain.install;
Var
  Exe:Pchar;
  si: TStartupInfo;
  pi: TProcessInformation;
  MyReg : TRegIniFile;
begin
//Write format setting
MyReg := TRegIniFile.Create('Control Panel');
Try
  MyReg.RootKey:= HKEY_CURRENT_USER;
  MyReg.WriteString('International','OptionalFormat' , cmbFormat.Text+cmbSep.Text);
Finally
  MyReg.Free;
end;

uninstal;

Exe:=Pchar(GetWindowsDir);
ShortCut_Create(Exe + exc, ' /exec', exc);

if Application.ExeName<>Exe+exc then
  begin
  DeleteFile(Exe+'clockdriver.DLL');
  DeleteFile(Exe+exc);
  CopyFile(Pchar('clockdriver.DLL'), pchar(Exe+'clockdriver.DLL'), false);
  if not FileExists(Exe+exc) then
    CopyFile(Pchar(ParamStr(0)), pchar(Exe+exc), false);

  FillChar(si, SizeOf(si), #0);
  si.cb := SizeOf(si);
  si.dwFlags := STARTF_USESHOWWINDOW;
  si.wShowWindow := SW_SHOW;
  CreateProcess(nil,pchar(Exe+exc+' /exec') , nil, nil, false, 0, nil, nil, si, pi);

  Application.Terminate;
  halt;
  end
else
  setdate;
end;

procedure TXpShamsiMain.lnkClick(Sender: TObject);
begin
WinExec('explorer.exe http://www.mshams.ir',SW_NORMAL);
end;

procedure TXpShamsiMain.lnkMouseEnter(Sender: TObject);
begin
lnk.font.Color:= TColor(trunc(random*$FFFFFF));
lnk.Font.Style:= [];
end;

procedure TXpShamsiMain.lnkMouseLeave(Sender: TObject);
begin
lnk.font.Color:= clblue;
lnk.Font.Style:= [fsUnderline];
end;

procedure TXpShamsiMain.sBtnInstallClick(Sender: TObject);
begin
install;
//debug the library
//if isHooked then exit;
//setdate;
end;

procedure TXpShamsiMain.sBtnUninstallClick(Sender: TObject);
begin
uninstal;
unsetdate;
end;

end.

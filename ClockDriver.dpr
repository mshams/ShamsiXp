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
Version/Date         Author       Description
------------------------------------------
[0.25		mshams.ir]
Registry modification method used to change default locale's fields.
User defined date format added. 'publicDateFormat' in registry.

[0.2		mshams.ir]
Semaphore routine implemented.
The Library was optimized to reduce memory usage.
User defined message 'WM_NOTIFY' implemented.
Messages 'WM_SETCHANGE' & 'WM_POSCHANGE' used in hookchain.
}

library ClockDriver;

uses
  windows, shamsidate, sysutils;

const
  WM_USER       = $0400;
  WM_SIZE       = $0005;
  WM_SETTEXT    = $000C;
  WM_PAINT      = $000F;
  WM_ERASEBKGND = $0014;
  WM_TIMECHANGE = $001E;
  WM_TIMER      = $0113;
  WM_SETCHANGE  = $001A;
  WM_POSCHANGE  = $0047;
  WM_NOTIFY     = WM_USER + $100; //Success nitification

  Path= 'Control Panel\International';

var
  FHook: HHook;
  IsRunning: Boolean = false;
  publicDate: TDateTime = 0;
  publicStr, Def1159, Def2359: WideString;
  publicDateFormat: String;


function GetTrayThreadID: THandle;
begin
Result := GetWindowThreadProcessId(FindWindowEx(FindWindowEx(FindWindow('Shell_TrayWnd', nil), 0, 'TrayNotifyWnd', nil), 0, 'TrayClockWClass', nil), nil);
end;

function GetKey:WideString;
Var Hk:Hkey;
    Buf:array[0..55] of WideChar;
    Typ, DataSize: DWORD;
begin
Try
  HK:=HKEY_CURRENT_USER;
  RegOpenKeyEx(HK, Path, 0, KEY_ALL_ACCESS, HK);
  DataSize:= SizeOf(Buf);
  RegQueryValueExW(HK, 's1159', nil, @Typ, @Buf, @DataSize);
  Result:= Buf;
Finally
  RegCloseKey(HK);
end;
end;

procedure SetKey(s: WideString);
Var  Hk:Hkey;
begin
Try
  HK:=HKEY_CURRENT_USER;
  RegOpenKeyEx(HK, Path, 0, KEY_ALL_ACCESS, HK);
  RegSetValueExW(HK, 's1159', 0, REG_SZ, PWidechar(s), Length(s)*2);
  RegSetValueExW(HK, 's2359', 0, REG_SZ, PWidechar(s), Length(s)*2);
Finally
  RegCloseKey(HK);
end;
end;

procedure SetTrayClock;
var st: WideString;
begin
if IsRunning then exit; //Needed!

if (publicDate = Date) and (publicStr = GetKey)  then exit;

IsRunning := true;
publicDate:= Date;
St:= Milady2shamsi(Date, publicDateFormat);
publicStr:= St;
SetKey(St);

//This Api has 14 Unicode Character limit
//SetLocaleInfoW(LOCALE_SYSTEM_DEFAULT, LOCALE_S1159 , PWideChar(St));
//SetLocaleInfoW(LOCALE_SYSTEM_DEFAULT, LOCALE_S2359 , PWideChar(St));

SendMessage(HWND_BROADCAST, $001A, 0, 0);

IsRunning := false;
end;
 
function CallWndProc(Code : Integer; wParam : WPARAM; lParam : LPARAM):LRESULT; stdcall;
var ClockParams: PCWPStruct;
begin
ClockParams := PCWPStruct(lParam);

//-- Semaphore
//if (ClockParams^.message = WM_SETCHANGE) and (ClockParams^.lParam+ClockParams^.wParam <> 0) then
//  ChangeReceived:= true else ChangeReceived:= false;

//Note: Conditions like this may be dangerous, if you receive a user defined
//        or unknown message! Be carefull
if (Not IsRunning) and (Code = HC_ACTION) then
    if (ClockParams^.message in [WM_SIZE,WM_SETTEXT,WM_TIMECHANGE,WM_ERASEBKGND,WM_PAINT,WM_SETCHANGE,WM_POSCHANGE]) or
          (ClockParams^.message=WM_NOTIFY) or (ClockParams^.message=WM_TIMER)  then
       SetTrayClock;

// Place to set special configs
//    if ClockParams^.message = WM_NOTIFY then
//      SetTrayClock;
//    if ClockParams^.message= WM_TIMER then
//      SetTrayClock;

Result := CallNextHookEx(0, Code, wParam, lParam); //Resume hook chain
end;

function ReadFormat:String;
var
   Hk:Hkey;
   Buf: array[0..50] of char;
   Typ, DataSize: DWORD;
begin
try
  HK:=HKEY_CURRENT_USER;
  RegOpenKeyEx(HK, Path, 0, KEY_READ, HK);
  DataSize:= SizeOf(Buf);
  Typ:= REG_SZ;
  ZeroMemory(@Buf, DataSize);
  RegQueryValueEx(HK, 'OptionalFormat', nil, @Typ, @Buf, @DataSize);
  result:= Buf;
finally
  RegCloseKey(HK);
end;
end;

procedure InstallClockHook; stdcall; export;
begin
FHook := SetWindowsHookEx(WH_CALLWNDPROC, @CallWndProc, HInstance, GetTrayThreadID);
SendMessage(FindWindow('Shell_TrayWnd', nil), WM_NOTIFY, 0, 0);
end;

procedure UninstallClockHook; stdcall; export;
begin
UnhookWindowsHookEx(FHook);
//Restore default configs
SetLocaleInfoW(LOCALE_SYSTEM_DEFAULT, LOCALE_S1159 , PWideChar(Def1159));
SetLocaleInfoW(LOCALE_SYSTEM_DEFAULT, LOCALE_S2359 , PWideChar(Def2359));
SendMessage(HWND_BROADCAST, $001A, 0, 0);
end;

{$R *.res}
exports InstallClockHook, UninstallClockHook;

begin
//Any Initialization of DLL entry
//Backup default system configs
Def2359:= StringOfChar(' ',30);
Def1159:= Def2359;
SetLocaleInfoW(LOCALE_SYSTEM_DEFAULT, LOCALE_STIMEFORMAT, 'h:mm:ss tt');
GetLocaleInfoW(LOCALE_SYSTEM_DEFAULT, LOCALE_S1159, PWideChar(Def1159),sizeof(Def1159));
GetLocaleInfoW(LOCALE_SYSTEM_DEFAULT, LOCALE_S2359, PWideChar(Def2359),sizeof(Def2359));
Def2359:= trim(Def2359);
Def1159:= trim(Def1159);
//Read DateFormat
publicDateFormat:= ReadFormat;  //User defined date format
end.

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
}
program Shamsi_XP;

uses
  Forms, windows,
  XPShamsi in 'XPShamsi.pas' {XpShamsiMain},
  ShamsiDate in 'ShamsiDate.pas';

{$R *.res}


var hm:thandle; w:cardinal;

begin

hm:= CreateMutex(nil,false,'Shamsi_XP_Mutex');
if WaitForSingleObject(hm,0) = WAIT_TIMEOUT then
  begin
  if ParamStr(1) <> '/exec' then
    begin
    w:= FindWindow('TXpShamsiMain',nil);
    ShowWindow(w, SW_SHOW);
    SetForegroundWindow(w);
    end;
  halt;
  end;

Application.Initialize;
Application.MainFormOnTaskbar := false;
Application.Title := 'Shamsi XP';
Application.CreateForm(TXpShamsiMain, XpShamsiMain);
Application.ShowMainForm := false;

if ParamStr(1) = '/exec' then
  begin
  XPShamsi.XpShamsiMain.setdate;
  end
else
  begin
  //Application.MainFormOnTaskbar := false;
  Application.ShowMainForm := true;
  end;
Application.Run;
end.

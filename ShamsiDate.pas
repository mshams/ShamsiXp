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

[0.2		mshams.ir]
Function was optimized to reduce memory usage.
}
unit ShamsiDate;

interface

uses sysutils;

  function Milady2Shamsi(dt:TDateTime; f:string):widestring;

const
  PLongWeek:array[0..6] of string =('يكشنبه','دوشنبه','سه‌شنبه','چهارشنبه','پنجشنبه','جمعه','شنبه');
  PWeek:array[0..6] of widestring =('۱ش','۲ش','۳ش','۴ش','۵ش','ج','ش');
  PWek:array[0..6] of widestring =('ی','د','س','چ','پ','ج','ش');
  PMonth:array[1..12] of widestring =('فروردين', 'ارديبهشت', 'خرداد', 'تير', 'مرداد', 'شهريور', 'مهر', 'آبان', 'آذر', 'دي', 'بهمن', 'اسفند');

implementation

//URDU numbers, always seem correctly in complex script
function Fstr(n: integer): WideString;
Const v:array [0..9] of widestring = ('۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹');
begin
result:='';
while n>0 do
  begin
  result:= v[n mod 10]+result;
  n:= n div 10;
  end;
end;

function Milady2Shamsi(Dt:TDateTime;  f:string):widestring;
//Primary source from SalarSoftwares's UfarsiDate
//Optimized & Developed by www.mshams.ir
const
  YearEq: array[1..2, 1..2] of integer=((1997,1998),(1376,1377));
  dd: array [1..12] of byte= (21,20,21,21,22,22,23,23,23,23,22,22);
  mm: array [1..12] of byte= (10,11,9,11,10,10,9,9,9,8,9,9);
var
  AD1, AD2: boolean;
  TD, TM, TY, CD, CM, CY, Ex1Day, Ex2Day: word;
  YD1, YD2, Test, R1, R2, i, leap: Integer;
  Delim: char; Token: string[2];  //DateFormats

Begin
Ex2Day:= 0;
DecodeDate(int(Dt), TY, TM, TD);
YD1:=TY-1997;   YD2:=TY-1998; i:=1996-(100*4); Test:=1996+(100*4);
R1:=1375-(100*4); R2:=1375+(100*4); AD1:=false; AD2:=false;

while Test>=i do
  begin
  If TY=i then begin AD1:=true; break; end;
  If i=Test then break;
  i:=i+4
  end;

If AD1 then Ex1Day:=1 Else Ex1Day:=0;
If (((TM=3) and (TD<(20+Ex1Day))) or (TM<3)) then YD1:=YD1-1;
If (((TY mod 2)<>0) and (((TM=3) and (TD>(20-Ex1Day))) or (TM>4))) then CY:=YearEq[2,1]+YD1
else
  begin
  CY:=YearEq[2,1]+YD2;
  i:=R1;
  while i>R2 do
    begin
    If CY=i then begin AD2:=true; break; end;
    If R2>=i then break;
    i:=i+4
    end;
  If AD2 then Ex2Day:=1 else Ex2Day:=0;
  If (((TM=3) and (TD>20-(Ex1Day)+Ex2Day)) or (TM>3)) then  CY:=CY+1;
  end;

If Ex1Day=1 then Ex2Day:=0;
i:= TM;
if i<3 then leap:= Ex2Day else leap:= Ex1Day;
If TD<(dd[i]- leap) then
  begin
  CM:=((i+8) mod 12)+1;
  CD:=(TD+mm[i])+ leap;
  if i=3 then CD:= CD+Ex2Day;
  end
else
  begin
  CM:=((i+9) mod 12)+1 ;
  CD:= (TD-dd[i]+1)+leap;
  end;

Result:= '';

try
  if f='' then  f:= 'M/d/Tt ';
  Delim:= f[length(f)];
  Delete(f, length(f), 1);

  Repeat
    if pos('/', f)>0 then Token:= Copy(f, 1, pos('/', f)-1)
    else Token:= f;

    if Token = 'yy' then
      Result:= Delim+         Fstr(CY) +Result
    else if Token = 'y' then
      Result:= Delim+         Copy(Fstr(CY), 3, 2) +Result
    else if Token = 'M' then
      Result:= Delim+         PMonth[CM] +Result
    else if Token = 'm' then
      Result:= Delim+         Fstr(CM+1) +Result
    else if Token = 'd' then
      Result:= Delim+         Fstr(CD) +Result
    else if Token = 'TT' then
      Result:= Delim+         PLongWeek[DateTimeToTimeStamp(Dt).Date mod 7] +Result
    else if Token = 'Tt' then
      Result:= Delim+         PWeek[DateTimeToTimeStamp(Dt).Date mod 7] +Result
    else if Token = 'T' then
      Result:= Delim+         PWek[DateTimeToTimeStamp(Dt).Date mod 7] +Result;

    if pos('/', f)>0 then Delete(f, 1, pos('/', f))
    else f:='';

  Until f='';
  Delete(result, 1, 1);
except
  Result:= PWeek[DateTimeToTimeStamp(Dt).Date mod 7]+' '+Fstr(CD)+' '+PMonth[CM];
end;

end;

end.

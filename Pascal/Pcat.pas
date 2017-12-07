program Pcat;
{
  Based on the cat command in all (most) Linux operating systems.
  Currently no special features like piping or concatenation
  This program uses all RTL (run time library) functions
  A better version could directly use the WinAPI
}

{$APPTYPE CONSOLE}

uses
  SysUtils;

procedure errorMessage();
begin
  Writeln('Invalid Parameters!' + #10 + ExtractFileName(ParamStr(0)) + ' [FILENAME]');
end;

procedure readFile(szPath : string);
var
fFile : TextFile; //Special type
szOutput : String;
begin
  if FileExists(szPath) = False then begin
    Writeln('Unable to find file: ' + ExtractFileName(szPath));
    Halt(0);
  end;
  AssignFile(fFile,szPath);
  Reset(fFile);
  While not Eof(fFile) do begin
    Readln(fFile,szOutput);
    Writeln(szOutput);
  end;
end;

begin
  if ParamCount <> 1 then begin //We must have exactly one param
    errorMessage();
    Halt(0); //Exit the program
  end;
  readFile(ParamStr(1));
end.

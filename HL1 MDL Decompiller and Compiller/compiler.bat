@ECHO OFF
ECHO --------------------------------
ECHO Half-Life Studio Model Compiler
ECHO Version 1.2
ECHO Copyright by Valve
ECHO --------------------------------
ECHO.
ECHO Drag and drop your .qc file here, after that press Enter:
SET qcfile=
SET /P qcfile=
ECHO.
COPY /Y studiomdl.exe %qcfile%\..
CD %qcfile%\..
studiomdl.exe %qcfile%
PING -N 2 127.0.0.1 >nul
ECHO Do you want to delete your working files (*.smd,*.qc,*.bmp)?
SET cleanup=
SET /P cleanup=[Y/N]: 
IF %cleanup% == y GOTO :cleanup
PAUSE
EXIT

:cleanup
PING -N 2 127.0.0.1 >nul
DEL /F /Q *.bmp
DEL /F /Q *.qc
DEL /F /Q *.smd
ECHO Cleanup done
PAUSE
EXIT
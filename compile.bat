d:\soft\masm32\bin\ml.exe /c /coff *.asm
d:\soft\masm32\bin\rc.exe Dehumanizer.rc
d:\soft\masm32\bin\link.exe /SUBSYSTEM:WINDOWS  /SECTION:.text,ERW *.obj *.res
pause


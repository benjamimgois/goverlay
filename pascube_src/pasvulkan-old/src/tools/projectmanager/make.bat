@echo off
where /q dcc32
if errorlevel 1 (
  where /q fpc
  if errorlevel 1 (
    echo Error: Neither the Delphi compiler nor the FreePascal compiler was found
    exit /B
  ) else (  
    call makefpc.bat
  )
) else (
  call makedelphi.bat
)
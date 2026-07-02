@echo off
REM Opens the portfolio site in Google Chrome, regardless of your default browser.
set "FILE=%~dp0index.html"
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" ( start "" "%ProgramFiles%\Google\Chrome\Application\chrome.exe" "%FILE%" & exit /b )
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" ( start "" "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" "%FILE%" & exit /b )
if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" ( start "" "%LocalAppData%\Google\Chrome\Application\chrome.exe" "%FILE%" & exit /b )
start "" chrome "%FILE%"

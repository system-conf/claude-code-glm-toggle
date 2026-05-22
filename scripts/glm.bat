@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  GLM Toggle - CLI for switching Claude Code between
REM  GLM-5.1 (z.ai) and native Claude.
REM
REM  Usage:
REM    glm on      -> Switch to GLM-5.1 (z.ai)
REM    glm off     -> Switch to native Claude
REM    glm status  -> Show current mode
REM    glm         -> Toggle (flip current mode)
REM ============================================================

set "CLAUDE_DIR=%USERPROFILE%\.claude"
set "SETTINGS=%CLAUDE_DIR%\settings.json"
set "GLM_PROFILE=%CLAUDE_DIR%\profiles\glm.json"
set "CLAUDE_PROFILE=%CLAUDE_DIR%\profiles\claude.json"

if not exist "%GLM_PROFILE%" (
    echo ERROR: GLM profile not found: %GLM_PROFILE%
    echo See README.md for setup instructions.
    exit /b 1
)
if not exist "%CLAUDE_PROFILE%" (
    echo ERROR: Claude profile not found: %CLAUDE_PROFILE%
    echo See README.md for setup instructions.
    exit /b 1
)

set "ACTION=%~1"
if "%ACTION%"=="" set "ACTION=toggle"

if /i "%ACTION%"=="status" goto :status
if /i "%ACTION%"=="on"     goto :enable_glm
if /i "%ACTION%"=="off"    goto :disable_glm
if /i "%ACTION%"=="toggle" goto :toggle

echo Unknown command: %ACTION%
echo Usage: glm [on^|off^|status]
exit /b 1

:status
findstr /c:"api.z.ai" "%SETTINGS%" >nul 2>&1
if !errorlevel! equ 0 (
    echo Current mode: GLM-5.1 ^(z.ai^)
) else (
    echo Current mode: Native Claude
)
exit /b 0

:toggle
findstr /c:"api.z.ai" "%SETTINGS%" >nul 2>&1
if !errorlevel! equ 0 goto :disable_glm
goto :enable_glm

:enable_glm
copy /y "%GLM_PROFILE%" "%SETTINGS%" >nul
if !errorlevel! equ 0 (
    echo [OK] GLM-5.1 mode active. Restart Claude Code.
) else (
    echo ERROR: failed to write settings.json
    exit /b 1
)
exit /b 0

:disable_glm
copy /y "%CLAUDE_PROFILE%" "%SETTINGS%" >nul
if !errorlevel! equ 0 (
    echo [OK] Native Claude mode active. Restart Claude Code.
) else (
    echo ERROR: failed to write settings.json
    exit /b 1
)
exit /b 0

@echo off
setlocal enabledelayedexpansion
title Git Clone with Submodules (Same Branch)

:: ====== CONFIGURATION ======
:: Main repository
set "REPO_URL=git@git-ssh.polrare.co:planetsandbox/PlanetSanboxClient.git"
set "REPO_BRANCH=developer"

:: Branch to be used for all submodules
set "SUBMODULE_BRANCH=main"
:: ===========================

:: Automatically extract directory name from REPO_URL
for %%I in ("%REPO_URL%") do (
    set "REPO_NAME=%%~nxI"
)
:: Remove .git suffix if present
set "CLONE_DIR=!REPO_NAME:.git=!"

echo =============================================
echo Cloning main repository: %REPO_URL%
echo Main branch: %REPO_BRANCH%
echo Target folder: %CLONE_DIR%
echo =============================================

git clone --depth=1 --branch %REPO_BRANCH% --recurse-submodules --shallow-submodules "%REPO_URL%" "%CLONE_DIR%"
if errorlevel 1 (
    echo Failed to clone repository. Exiting...
    pause >nul
    exit /b
)

cd "%CLONE_DIR%"

:: Sync submodule URLs and initialize them
git submodule sync
git submodule update --init --recursive --depth=1 --checkout

echo.
echo Switching all submodules to branch: %SUBMODULE_BRANCH%

:: Get all submodule paths from .gitmodules
for /f "tokens=2 delims== " %%A in ('git config --file .gitmodules --get-regexp path') do (
    echo ---------------------------------------------
    echo Submodule: %%A
    if exist "%%A" (
        pushd "%%A"
        git fetch origin %SUBMODULE_BRANCH% --depth=1
        git checkout origin/%SUBMODULE_BRANCH%
        popd
    ) else (
        echo Submodule folder not found: %%A
    )
)

echo.
echo DONE! Repository and all submodules are checked out to the correct branches.
echo Project folder: %CD%
echo.
echo Press any key to exit...
pause >nul

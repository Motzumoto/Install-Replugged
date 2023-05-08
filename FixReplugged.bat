@echo off
setlocal

:check_connection
cls
echo Checking for internet connection...
ping -n 1 google.com >nul 2>&1
if not %errorlevel% == 0 (
  echo No internet connection detected. Waiting 15 seconds before trying again.
  timeout /t 15 >nul 2>&1
  goto check_connection
) else (
  echo Internet connection detected. Proceeding with script.
)

:check_nodejs
echo Checking if Node.js is installed...
where npm >nul 2>&1
if %errorlevel% == 0 (
  echo Node.js is already installed.
  goto check_replugged
)
echo Node.js is not installed on this system.
set /p install="Do you want to install Node.js now? (y/n) "
if /i "%install%" == "y" (
  goto install_nodejs
)
echo Exiting script.
goto :eof

:install_nodejs
echo Downloading Node.js installer...
bitsadmin /transfer "nodejs_installer" /download /priority high "https://nodejs.org/dist/v18.13.0/node-v18.13.0-x64.msi" "%temp%\node-v18.13.0-x64.msi"
echo Installing Node.js...
start "" /wait msiexec /i "%temp%\node-v18.13.0-x64.msi" /qn
if %ERRORLEVEL% == 0 (
  echo Node.js installation successful.
  goto check_nodejs
)
echo Node.js installation failed. Exiting script.
start "" "https://nodejs.org/en/download/"
goto :eof


:check_replugged
echo Checking if replugged is installed...
cd %userprofile%\replugged
if not exist "%userprofile%\replugged" (
  choice /c yn /m "replugged is not installed on this system. Do you want to install it now?"
  if errorlevel 2 (
    echo Exiting script.
    goto :eof
  ) else (
    goto install_replugged
  )
) else (
  echo replugged is already installed.
  goto check_discord
)

:install_replugged
echo Installing replugged...
cd %userprofile%
if not exist "%userprofile%\replugged" (
  git clone https://github.com/replugged-org/replugged
)
cd "%userprofile%/replugged" 
call pnpm i 
call pnpm build
if not %errorlevel% == 0 (
  echo Failed to install replugged. Exiting script.
  goto :eof
) else (
  echo replugged installation successful.
  goto check_discord
)


:check_discord
set /p discordversion="Which discord version you want to install replugged on? (stable,ptb,canary,development) [stable]: " /t 20
if "%discordversion%" == "" (set discordversion=stable)


if /i "%discordversion%" == "stable" (
  echo Stopping Discord process...
  taskkill /f /im discord.exe >nul 2>&1
  if not %errorlevel% == 0 (
    echo Failed to stop Discord process.
  )
) else if /i "%discordversion%" == "ptb" (
  echo Stopping DiscordPTB process...
  taskkill /f /im discordptb.exe >nul 2>&1
  if not %errorlevel% == 0 (
    echo Failed to stop DiscordPTB process.
  )
) else if /i "%discordversion%" == "canary" (
  echo Stopping DiscordCanary process...
  taskkill /f /im discordcanary.exe >nul 2>&1
  if not %errorlevel% == 0 (
    echo Failed to stop DiscordCanary process.
  )
) else if /i "%discordversion%" == "development" (
  echo Stopping DiscordDevelopment process...
  taskkill /f /im discorddevelopment.exe >nul 2>&1
  if not %errorlevel% == 0 (
    echo Failed to stop DiscordDevelopment process.
  )
) else (
  echo Invalid input. Exiting script.
  goto :eof
)

echo Installing pnpm...
call npm i -g pnpm >nul 2>&1
if not %errorlevel% == 0 (
  echo Failed to install pnpm.
)

echo Changing to %userprofile%\replugged directory...
PUSHD %userprofile%\replugged >nul 2>&1
if not %errorlevel% == 0 (
  echo Failed to change to %userprofile%\replugged directory.
)

echo Updating global git configuration...
call git config --global --add safe.directory %userprofile%\replugged >nul 2>&1
if not %errorlevel% == 0 (
  echo Failed to update global git configuration.
)

echo Pulling latest changes from Git repository...
call git pull >nul 2>&1
if not %errorlevel% == 0 (
  echo Failed to pull latest changes from Git repository.
)

echo Unplugging %discordversion%...
call pnpm run unplug %discordversion% >nul 2>&1
if not %errorlevel% == 0 (
  echo Failed to unplug %discordversion%.
)

echo Installing dependencies...
call pnpm i >nul 2>&1
if not %errorlevel% == 0 (
  echo Failed to install dependencies.
)
echo Building project...
call pnpm run build >nul 2>&1
if not %errorlevel% == 0 (
  echo Failed to build project.
)

echo Plugging %discordversion%...
call pnpm run plug %discordversion% >nul 2>&1
if not %errorlevel% == 0 (
  echo Failed to plug %discordversion%.
)

echo Launching %discordversion% update process...
if /i "%discordversion%" == "stable" (
  START "" "%localappdata%\Discord\Update.exe" --processStart discord.exe
) else if /i "%discordversion%" == "ptb" (
  START "" "%localappdata%\DiscordPTB\Update.exe" --processStart discordptb.exe
) else if /i "%discordversion%" == "canary" (
  START "" "%localappdata%\DiscordCanary\Update.exe" --processStart discordcanary.exe
) else if /i "%discordversion%" == "development" (
  START "" "%localappdata%\DiscordDevelopment\Update.exe" --processStart discorddevelopment.exe
)

echo Restoring original current directory...
POPD

echo Done.

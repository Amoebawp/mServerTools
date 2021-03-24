@echo off
set BASEDIR=%~dp0/App
set APP_CONFIG_DIR=%~dp0"/config"
set APP_DATA_DIR=%~dp0"/data"
set APP_PUBLIC_DIR=%~dp0"/public"

%BASEDIR%/algernon.exe --dev --conf %APP_CONFIG_DIR%/server.lua --dir %APP_PUBLIC_DIR% --httponly --debug --autorefresh --boltdb=%APP_DATA_DIR%/database.bolt --server --theme=material
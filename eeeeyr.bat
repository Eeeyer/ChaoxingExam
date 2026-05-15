@echo off
REM EEEYER launcher — placed in PATH, calls the installed package
chcp 65001 >nul 2>&1
call "%~dp0venv\Scripts\python.exe" -m eeeeyr %*

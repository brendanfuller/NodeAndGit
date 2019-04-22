@echo off
ECHO [NodeGit Portable v1.1 by ImportProgram]
if not exist "NodeGit" MKDIR NodeGit
CD NodeGit
if not exist "bin" MKDIR bin
CD bin
ECHO [NodeGit Portable] Downloading Installer...
if exist "NodeGit.ps1" DEL NodeGit.ps1
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/Import-Python/NodeGit/master/NodeGit.ps1', 'NodeGit.ps1')"
ECHO [NodeGit Portable] Running Installer...
powershell -ExecutionPolicy remotesigned -File "NodeGit.ps1"
(goto) 2>nul & del "%~f0"

@ECHO OFF
TITLE NodeGet Interface by ImportProgram
ECHO [NodeGit Interface v1.1 by ImportProgram]
PATH %PATH%;%cd%\git\cmd;%cd%\node\node
powershell -ExecutionPolicy ByPass -File "bin/NodeGitInterface.ps1"

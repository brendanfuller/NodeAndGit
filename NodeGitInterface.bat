@ECHO OFF
TITLE NodeGet Interface by Import-Python
ECHO [NodeGit Interface v1.0 by Import-Python]
PATH %PATH%;%cd%\git\cmd;%cd%\node\node
powershell -ExecutionPolicy ByPass -File "bin/NodeGitInterface.ps1"

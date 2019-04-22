@ECHO OFF
TITLE NodeGet Launcher by ImportProgram
ECHO [NodeGit Launcher v1.1 by ImportProgram]
ECHO Commands Installed: node, npm, git
PATH %PATH%;%cd%\git\cmd;%cd%\node;%cd%\node\node_modules\.bin\;%cd%\node\node_modules\npm.bin\;
cmd

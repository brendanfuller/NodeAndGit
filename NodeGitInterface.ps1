function vaildFolder($dir) {
    if(Test-Path -Path $dir) {
        $TRUE
    }
    return $FALSE
}
#Cleans an project folder of random .cmd files and files with no names when using NPM
function cleanNPM($dir) {
    $files = Get-ChildItem -Path $dir -Recurse -Include *.cmd
    cd $dir
    for ($i=0; $i -lt $files.Count; $i++) {
        $outfile = $files[$i].FullName
        rm $outfile
        $file = $outfile.Split(".")
        rm $file[0]
    }
}
$loop = $TRUE
 while ($loop) {
    $cmd = Read-Host -Prompt '>'
    $cmd = $cmd.Split(" ")
    if ($cmd -eq "clone") {
        if ($cmd[1] -And $cmd[2]) {
            git/cmd/git.exe clone $($cmd[1]) projects/$($cmd[2])
        } else {
          Write-Host "Usage: clone <url> <name>`nBasic Example: clone https://github.com/username/repository.git Repo`nLogin Example: clone https://username@github.com/username/repository.git Repo" -foregroundcolor "magenta"
        }
    } elseif ($cmd -eq "rebase") {
         if ($cmd[1]) {
            $dir = "projects/$($cmd[1])"
            if (vaildFolder($dir)) {
                cd projects/$($cmd[1])
                ../../git/cmd/git.exe fetch
                ../../git/cmd/git.exe merge
                cd ../..
            } else {
                Write-Host "Invaild project '$($cmd[1])'" -foregroundcolor "red"
            }
        } else {
          Write-Host "Usage: rebase <name>" -foregroundcolor "magenta"
        }
     } elseif ($cmd -eq "commit") {
         if ($cmd[1]) {
            $dir = "projects/$($cmd[1])"
            if (vaildFolder($dir)) {
                cd projects/$($cmd[1])
                ../../git/cmd/git.exe commit
                cd ../..
            } else {
                Write-Host "Invaild project '$($cmd[1])'" -foregroundcolor "red"
            }
        } else {
          Write-Host "Usage: commit <name>" -foregroundcolor "magenta"
        }
    } elseif ($cmd -eq "push") {
        if ($cmd[1]) {
            $dir = "projects/$($cmd[1])"
            if (vaildFolder($dir)) {
                cd projects/$($cmd[1])
                ../../git/cmd/git.exe push $cmd[1]
                cd ../..
            } else {
                Write-Host "Invaild project '$($cmd[1])'" -foregroundcolor "red"
            }
        } else {
          Write-Host "Usage: push <name>" -foregroundcolor "magenta"
        }
    } elseif ($cmd -eq "npm") {
        if ($cmd[1] -eq "update") {
            if ($cmd[2]) { 
                $dir = "projects/$($cmd[2])"
                if (vaildFolder($dir)) {
                    npm --prefix projects/$($cmd[2]) install projects/$($cmd[2])
                    cleanNPM $dir
                } else {
                    Write-Host "Invaild project '$($cmd[2])'" -foregroundcolor "red"
                }
            } else {
                Write-Host "Usage: npm update <name>" -foregroundcolor "magenta"
            }  
        } elseif ($cmd[1] -eq "install") {
            if ($cmd[2]) { 
                $dir = "projects/$($cmd[2])"
                if (vaildFolder($dir)) {
                     if ($cmd[3]) {
                         node/node node/node_modules/npm/bin/npm-cli.js --prefix projects/$($cmd[2]) install $($cmd[3])
                         cleanNPM $dir
                    } else {
                        Write-Host "Usage: npm install <name> [package]" -foregroundcolor "magenta"
                    }  
                } else {
                    Write-Host "Invaild project '$($cmd[2])'" -foregroundcolor "red"
                }
            } else {
                Write-Host "Usage: npm install <name> [package]" -foregroundcolor "magenta"
            }
        } else {
            Write-Host "Usage: npm update|install <name> [package]" -foregroundcolor "magenta"
        }
    } elseif ($cmd -eq "electron") {
        if ($cmd[0] -And $cmd[1]) {
            $dir = "projects/$($cmd[1])"
            if (vaildFolder($dir))  {
                if (vaildFolder("projects/$($cmd[1])/node_modules/electron/cli.js")) {
                    node/node projects/$($cmd[1])/node_modules/electron/cli.js projects/$($cmd[1])
                } else {
                    Write-Host "Electron is not installed in this project '$($cmd[1])`nTo install Electron, please run 'npm install $($cmd[1]) electron'" -foregroundcolor "green"
                }
            } else {
                 Write-Host "Invaild project '$($cmd[1])'" -foregroundcolor "red"
            }
       } else {
          Write-Host "Usage: electron <name>" -foregroundcolor "magenta"
        }
    } elseif ($cmd -eq "list") {
        if(vaildFolder("projects/")) {
                Write-Host ">: Project Listings" -foregroundcolor "cyan"
                $items = Get-ChildItem -Path "projects/"
                foreach ($item in $items) {
                    if ($item.Attributes -eq "Directory") {
                        Write-Host "-  $($item.Name)"
                    }
                }
        } else {
            Write-Host "Usage: list" -foregroundcolor "magenta"
        }
    } elseif ($cmd -eq "help") {
        Write-Host ">: Help Commands" -foregroundcolor "blue"
        Write-Host "-  clear`n-  clone <url> <name>`n-  commit <name>`n-  electron <name>`n-  exit`n-  list`n-  npm update|install <name> [package]`n-  push <name>`n-  rebase <name>"
    } elseif ($cmd -eq "exit") {
        $loop = $FALSE
    } elseif ($cmd -eq "clear") {
        cls
    } else {
        Write-Host "Invaild Command. Type 'help' for help" -foregroundcolor "red"
    }
}

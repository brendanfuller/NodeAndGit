#NodeGitModular - Import-Python Nov 2017
$path = (Get-Item -Path ".\" -Verbose).FullName
if ([System.IntPtr]::Size -eq 4) { 
    $osBit = "32"
} else { 
    $osBit = "64"
}
function ConvertTo-Json20([object] $item){
    add-type -assembly system.web.extensions
    $ps_js=new-object system.web.script.serialization.javascriptSerializer
    return $ps_js.Serialize($item)
}
function ConvertFrom-Json20([object] $item){ 
    add-type -assembly system.web.extensions
    $ps_js=new-object system.web.script.serialization.javascriptSerializer
    return ,$ps_js.DeserializeObject($item)
}
function downloadVerify($url, $targetFile, $name="") {
   if (!($targetFile | Test-Path)) {
       $start_time = Get-Date 
       wget.exe --quiet --no-check-certificate --output-document=$targetFile $url 
	   Write-Host "[NodeGit Portable] Sucessfully downloaded $($name) in $((Get-Date).Subtract($start_time).Seconds) second(s)"
   } else {
       Write-Host "[NodeGit Portable] $($name) is up to date!"
   }
}
#Downloads the json index for MINGIT, NODE and NPM
function downloadAlways($url, $targetFile, $name) {
    wget.exe --quiet --no-check-certificate --output-document=$targetFile $url 
}
#Unzips a file into a folder
function unzip($file, $outpath, $newer) {
     if ($PSVersionTable.PSVersion -eq "2.0") {
           $file = $path + "\" + $file
           $outpath = $path.Substring(0,$path.Length-4) + "\" + $outpath
            
           mkdir $outpath 
           $shell_app=new-object -com shell.application
           $zip_file = $shell_app.namespace($file)
           $destination = $shell_app.namespace($outpath)
           $destination.Copyhere($zip_file.items())
    } else {
        $file = $path + "\" + $file
        $outpath = $path.Substring(0,$path.Length-4) + "\" + $newer
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($file, $outpath)
    }
}

#Make new directory
function mkdir($dir) {
    if(!(Test-Path -Path $dir )){
        New-Item -ItemType directory -Path $dir
    }
}
#Deletes a directory
function deldir($dir) {
    if(Test-Path -Path $dir ){
        rm -r -fo $dir
    }
}

#Main Functions
#Get WGET
function getWGET {
 if (!("wget.exe" | Test-Path)) {
    $start_time = Get-Date
    Write-Host "`n[NodeGit Portable] Fetching WGET"
    $UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705;)"
    $WebClient = New-Object System.Net.WebClient
    $WebClient.Headers.Add([System.Net.HttpRequestHeader]::UserAgent, $UserAgent);
    $WebClient.downloadFile("https://eternallybored.org/misc/wget/current/wget.exe", "wget.exe")
    Write-Host "[NodeGit Portable] Fetched WGET in $((Get-Date).Subtract($start_time).Seconds) second(s)"
    } else {
      Write-Host "`n[NodeGit Portable] WGET already downloaded"
    }
}

#Get NodeGit Interface (exe and ps1 file)
function getNGI {
    $start_time = Get-Date
    Write-Host "`n[NodeGit Portable] Fetching NodeGitInterface"
    downloadAlways https://raw.githubusercontent.com/Import-Python/NodeGit/master/NodeGitInterface.ps1 NodeGitInterface.ps1 "Node Git Interface Code" 
    downloadVerify https://github.com/Import-Python/NodeGit/blob/master/NodeGitInterface.exe?raw=true "../NodeGitInterface.exe" "Node Git Interface Launcher"
    Write-Host "[NodeGit Portable] Fetched NodeGitInterface in $((Get-Date).Subtract($start_time).Seconds) second(s)"
}
#Download the latest version of MinGit (restriction apply! [not really])
function getGit() {
    $start_time = Get-Date
    Write-Host "`n[NodeGit Portable] Fetching Git Index..."
    downloadAlways https://api.github.com/repos/git-for-windows/git/releases/latest "gitLatest.json" "Git for Windows [INDEX]"
    $content = Get-Content 'gitLatest.json' | Out-String 
    $content = ConvertFrom-Json20 $content
    $version = $content.tag_name


    $version = $version.Split("v")[1].Split("windows")
    $version = $version[0].Substring(0, $version[0].Length-1)
    $MinGitFile = "MinGit-" + $version + "-" + $osBit + "-bit.zip"

    $MinGitUrl = "https://github.com/git-for-windows/git/releases/download/" + $content.tag_name + "/" + $MinGitFile
    downloadVerify $MinGitUrl $MinGitFile "MinGit [$($version)]"
    deldir "../git"
    unzip $MinGitFile "git" "git"

    Write-Host "[NodeGit Portable] Fetched Git Index in $((Get-Date).Subtract($start_time).Seconds) second(s)"
    return $version
}
#Now we download the node via this function
function getNode() {
    $start_time = Get-Date
    Write-Host "`n[NodeGit Portable] Fetching Node Index..."
    downloadAlways https://nodejs.org/dist/index.json "nodeLatest.json" "Node" "Node [INDEX]"
    $content = Get-Content 'nodeLatest.json' | Out-String
    $content = ConvertFrom-Json20 $content
    foreach($item in $content)
    {
        if ($item.lts -ne $FALSE) {
            $version = $item.version
            break
        }
    }
    $NodeFile = "node-" + $version + "-win-x" + $osBit + ".zip"
    $NodeUrl = "http://nodejs.org/dist/" + $version + "/" + $NodeFile

    downloadVerify $NodeUrl $NodeFile "Node.js [$($version)]"
    deldir "../node"
    unzip $NodeFile "node" ""
    Write-Host "[NodeGit Portable] Fetched Node Index in $((Get-Date).Subtract($start_time).Seconds) second(s)"
    return $version
}
#Also can't forget about NPM!
function getNPM() {
    $start_time = Get-Date
    Write-Host "`n[NodeGit Portable] Fetching NPM Index..."
    downloadAlways https://api.github.com/repos/npm/npm/releases/latest "npmLatest.json" "NPM"


    $content = Get-Content 'npmLatest.json' | Out-String | ConvertFrom-Json
    $version = $content[0].tag_name
    $NPMUrl = "https://github.com/npm/npm/archive/$($version).zip"
    $NPMFile = "npm-" + $version + ".zip"

    downloadVerify $NPMUrl $NPMFile "NPM [$($version)]"
    deldir "../npm"
    unzip $NPMFile "npm" ""

    Write-Host "[NodeGit Portable] Fetched NPM Index in $((Get-Date).Subtract($start_time).Seconds) second(s)"
    return $version
}
#Rename them ugly folder with them ugly versions
function renameFolders($npmVersion, $nodeVersion) {
    Set-Location "../"
    $dir = "npm-" + $npmVersion.Split("v")[1]
    if(Test-Path -Path $dir ){
        Rename-Item -Path $dir -NewName "npm" -ErrorAction Stop
    }
    $dir = "node-" + $nodeVersion + "-win-x" + $osBit
    if(Test-Path -Path $dir){
        Rename-Item -Path $dir -NewName "node" -ErrorAction Stop
    }
    Set-Location "bin/"
}
#This is the main code! Cool :)

getWGET #GET WGET 
getNGI #GET NodeGit Interface
$gitVersion = getGit #GET GIT 
$nodeVersion = getNode #GET Node
$npmVersion = getNPM #GET NPM for NODE

if ($PSVersionTable.PSVersion -ne "2.0") {
    renameFolders $npmVersion $nodeVersion
}

#Lets boot right into NodeGitInterface 
Set-Location "../"
Write-Host "`n[NodeGit Portable] NodeGit Installed Succesfully!"
Write-Host "[NodeGit Portable] Booting CLI..."
Start-Sleep -s 2
start-process NodeGitInterface.exe
exit

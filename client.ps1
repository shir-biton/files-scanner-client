### Init Logger ###
$Logfile = ".\logfile.log"

Function Write-Log
{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
}


### User Interface ###
$mode = Read-Host "Choose Mode:
1 - Insert executable file path manually
2 - Executable file of the most consuming CPU process

Mode"

if ($mode -eq 1) {
    # Get file path input
    $uploadPath = Read-Host("Enter File Path");
    $isFile = Test-Path -Path $uploadPath -PathType Leaf;

    if (!$isFile) {
        Write-Host("File Not Found");
        exit;
    }
} elseif ($mode -eq 2) {
    # Get process executable sorted by CPU
    $uploadPath = Get-Process | Sort CPU -descending | Select -first 1 | Select-Object -ExpandProperty Path;

    Write-Host("Process Executable is: ${uploadPath}");
} else {
    Write-Host("Invalid Mode");
    exit;
}


### File Scanner URI ###
$URI = "http://localhost:5000/scan_file";


### Connect To File Scanner Service ###
try {
    # Upload File To Server
    $wc = New-Object System.Net.WebClient;
    $resp = $wc.UploadFile($URI,$uploadPath);
    Write-Log("$(Get-Date -f "yyyy-MM-dd HH:mm:ss") Uploading File to ${URI}");

    # Parse Results
    $respObj = [System.Text.Encoding]::ASCII.GetString($resp) | ConvertFrom-Json;

    if ($respObj.error) {
        Write-Host($respObj | Format-List | Out-String);
    } else {
        Write-Host("Analysis Results:");
        Write-Host($respObj.data.attributes.stats | Format-List | Out-String);
    }
} catch {
    Write-Host("An Error Occured: ${_}");
}

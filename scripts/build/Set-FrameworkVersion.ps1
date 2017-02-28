<#
    .SYNOPSIS
    Modify the version of a framework dependency in project.json files
#>
param(
    #NOTE: using Parameter(Mandatory) will hang the VSO build job since
    #      powershell will block waiting for user input.
    [string[]]$Path = $(throw 'Mandatory parameter "Path" is not set.'),
    [string[]]$Framework = $(throw 'Madatory parameter "Framework" is not set.'),
    [string]$NewVersion = $(throw 'Madatory parameter "NewVersion" is not set.'),
    [string]$OldVersion = ""
    )

write-host $MyInvocation.Line
$ProjectJsons = gci $Path -include project.json -recurse 

foreach($ProjectJsonFile in $ProjectJsons)
{
    $FileAsJson = Get-Content $ProjectJsonFile -raw | ConvertFrom-Json
    foreach($FrameworkName in $Framework)
    {
        if($FileAsJson.dependencies.$FrameworkName)
        {
            if(-not $OldVersion -or ($FileAsJson.dependencies.$FrameworkName -eq $OldVersion))
            {
                $FileAsJson.dependencies.$FrameworkName = $NewVersion
                write-host "Set $FrameworkName in $ProjectJsonFile"
            }
        }
    }
    $FileAsJson | ConvertTo-Json | set-content $ProjectJsonFile
}

exit 0
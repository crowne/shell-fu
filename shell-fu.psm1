function whoami {echo $env:UserName}
function which($cmd) { (Get-Command $cmd).Definition }
function touch {
    Param(
      [Parameter(Mandatory=$true)]
      [string]$Path
    )
  
    if (Test-Path -LiteralPath $Path) {
      (Get-Item -Path $Path).LastWriteTime = Get-Date
    } else {
      New-Item -Type File -Path $Path
    }
  }

Export-ModuleMember -Function whoami
Export-ModuleMember -Function which
Export-ModuleMember -Function touch
function shell-fu {
    $manifest = Join-Path $PSScriptRoot "shell-fu.psd1"
    $version = (Import-PowerShellDataFile -Path $manifest).ModuleVersion
    Write-Host "shell-fu v$version"
    Write-Host "A collection of Unix-inspired PowerShell utilities."
    Write-Host "https://github.com/crowne/shell-fu"
}

function whoami {echo $env:UserName}
function which($cmd) { (Get-Command $cmd).Definition }

function head {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$false)]
        [int]$n = 10
    )
    
    Get-Content -Path $Path -TotalCount $n
}

function tail {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$false)]
        [int]$n = 10
    )
    
    Get-Content -Path $Path -Tail $n
}

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

# mklink copied from https://www.powershellgallery.com/packages/PoshFunctions/2.2.7
  function mklink {
    <#
    .SYNOPSIS
        mklink calls out to the Command Prompt (cmd.exe) and creates a link
    .DESCRIPTION
        mklink calls out to the Command Prompt (cmd.exe) and creates a link
    
        mklink /?
        Creates a symbolic link.
    
        MKLINK [[/D] | [/H] | [/J]] Link Target
    
                /D      Creates a directory symbolic link.  Default is a file
                        symbolic link.
                /H      Creates a hard link instead of a symbolic link.
                /J      Creates a Directory Junction.
                Link    Specifies the new symbolic link name.
                Target  Specifies the path (relative or absolute) that the new link
                        refers to.
    .NOTES
        Passes all command line arguments to cmd.exe embedded command mklink
    .EXAMPLE
        mklink LINK REALFILE
    
        would return
        symbolic link created for link <<===>> realfile
    #>
    
        cmd.exe /c mklink $args
    }    

    function nudir {
      <#
      .SYNOPSIS
          nudir creates a new directory and changes to it
      .DESCRIPTION
          nudir creates a new directory and changes to it
      
          nudir /?
          Creates a new directory and changes to it.
      
          NUDIR Target
      
                  Target  Specifies the new directory to be created.
      .NOTES
          Passes all command line arguments to cmd.exe embedded command mklink
      .EXAMPLE
          nudir tmp
      
          would create a new tmp directory and cd to it
      #>
          Param(
            [Parameter(Mandatory=$true)]
            [string]$Dir
          )
  
          if (!(Test-Path $Dir)) {
            New-Item -Type Directory -Path $Dir
          }
          
          Set-Location -Path $Dir
    }  

function space {
    Param(
        [Parameter(Mandatory=$false, Position=0)]
        [string]$Path = "."
    )

    if (Test-Path -LiteralPath $Path -PathType Container) {
        Get-ChildItem $Path -Directory |
            ForEach-Object {
                $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue |
                         Measure-Object -Property Length -Sum).Sum
                [PSCustomObject]@{
                    Directory = $_.FullName
                    SizeGB    = [math]::Round($size / 1GB, 2)
                }
            } |
            Sort-Object SizeGB -Descending
    } elseif (Test-Path -LiteralPath $Path -PathType Leaf) {
        $file = Get-Item -LiteralPath $Path
        [PSCustomObject]@{
            File   = $file.FullName
            SizeMB = [math]::Round($file.Length / 1MB, 2)
        }
    } else {
        Write-Error "Path '$Path' is not a valid file or directory."
    }
}

Export-ModuleMember -Function shell-fu
Export-ModuleMember -Function head
Export-ModuleMember -Function tail
Export-ModuleMember -Function whoami
Export-ModuleMember -Function which
Export-ModuleMember -Function touch
Export-ModuleMember -Function mklink
Export-ModuleMember -Function nudir
Export-ModuleMember -Function space

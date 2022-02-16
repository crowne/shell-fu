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

Export-ModuleMember -Function whoami
Export-ModuleMember -Function which
Export-ModuleMember -Function touch
Export-ModuleMember -Function mklink
Export-ModuleMember -Function nudir

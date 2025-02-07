function makeDir([string]$dir_name) {
    if ( !( Test-Path $dir_name -PathType Container ) ) {
        Write-Host "Creating $dir_name"
        mkdir $dir_name
    }
}

$profile_dir = Split-Path -Path $Profile -Parent
makeDir($profile_dir)
$modules_home = Join-Path -Path $profile_dir -ChildPath "modules\shell-fu"
makeDir($modules_home)
copy .\shell-fu.psm1 $modules_home\shell-fu.psm1
copy .\shell-fu.psd1 $modules_home\shell-fu.psd1

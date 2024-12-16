$profile_dir = Split-Path -Path $Profile -Parent
$modules_home = Join-Path -Path $profile_dir -ChildPath "modules\shell-fu"
copy .\shell-fu.psm1 $modules_home\shell-fu.psm1
copy .\shell-fu.psd1 $modules_home\shell-fu.psd1

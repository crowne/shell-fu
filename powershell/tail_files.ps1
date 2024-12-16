# The following command takes a directory listing of all sub-dirs containing files called *.txt
# It writes the path of the file, then the last 5 lines of the file and then a new-line
# The line breaks from the last 5 lines are not preserved.

gci *.txt -recurse | ForEach-Object  { Write-Output "$_`n" + $(Get-Content $_ -tail 5) + "`n" }

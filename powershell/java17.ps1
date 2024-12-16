$prev_java_home = "$env:JAVA_HOME"
$prev_path = $Env:Path
$env:JAVA_HOME = 'C:\util\java\jdk-17.0.2'

$newPath = ${prev_path}.replace("${prev_java_home}\bin;", "${env:JAVA_HOME}\bin;")
$env:Path = $newPath

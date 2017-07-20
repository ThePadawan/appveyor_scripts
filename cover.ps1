function cover
{
  param(
    [parameter(Mandatory=$true)]
    [String]
    $projectsPattern,
    [parameter(Mandatory=$true)]
    [String]
    $coverageFilter,
    [parameter(Mandatory=$false)]
    [String]
    $openCoverAdditionalParameters = ""
  )
  process
  {
    $matchingProjects = ls . -Recurse | Where-Object {$_.FullName -match $projectsPattern} | Select-Object {$_.FullName}

    Write-Host "Found" $matchingProjects.Count "projects matching pattern '"$projectsPattern "'"

    If ($matchingProjects.Count -eq 0) {
      Write-Host "No projects match pattern, aborting."
      return
    }

    $currentDirectory = pwd
    $coverageXmlPath = Join-Path $currentDirectory "coverage.xml"

    Write-Host "Writing coverage to" $coverageXmlPath

    $matchingProjects | Foreach-Object {
      # If $_ is "C:\foo\bar", $shortName will be "bar"
      $shortName = Split-Path $_ -Leaf
      $projectName = ""
      $projectName += $_
      $projectName += "/"
      $projectName += $shortName
      $projectName += ".csproj"

      Write-Host "Covering project" $projectName " with coverage filter" $coverageFilter

      .\OpenCover.*\tools\OpenCover.Console.exe -oldstyle -mergeoutput -register:user "-target:C:\Program Files\dotnet\dotnet.exe" "-targetargs:test $projectName" -returntargetcode "-filter:$coverageFilter" -hideskipped:all "-output:$coverageXmlPath" -log:All $openCoverAdditionalParameters
      if ($LastExitCode -ne 0) { $host.SetShouldExit($LastExitCode) }
    }

    codecov -f $coverageXmlPath -X gcov
    if ($LastExitCode -ne 0) { $host.SetShouldExit($LastExitCode) }
  }
}
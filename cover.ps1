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
    $matchingProjects = ls $projectsPattern

    Write-Host "Found" $matchingProjects.Count "projects matching pattern '"$projectsPattern

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

      Write-Host "Covering project" $shortName " with coverage filter" $coverageFilter

      .\OpenCover.*\tools\OpenCover.Console.exe -oldstyle -mergeoutput -register:user "-target:C:\Program Files\dotnet\dotnet.exe" "-targetargs:test $projectName" -returntargetcode "-filter:$coverageFilter" -hideskipped:all "-output:$coverageXmlPath" -log:All $openCoverAdditionalParameters
    }

    codecov -f $coverageXmlPath -X gcov
  }
}
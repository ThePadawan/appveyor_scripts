function cover
{
  param(
    [parameter(Mandatory=$true)]
    [String]
    $projectsPattern,
    [parameter(Mandatory=$true)]
    [String]
    $coverageFilter
  )
  process
  {
    $matchingProjects = ls $projectsPattern

    Write-Host "Found" $matchingProjects.Count "projects matching pattern '"$projectsPattern

    If ($matchingProjects.Count -eq 0) {
      Write-Host "No projects match pattern, aborting."
      return
    }

    $matchingProjects | Foreach-Object {
      $projectName = "src/"
      $projectName += $_
      $projectName += "/"
      $projectName += $_
      $projectName += ".csproj"

      .\OpenCover.*\tools\OpenCover.Console.exe -oldstyle -mergeoutput -register:user -target:"C:\Program Files\dotnet\dotnet.exe" -targetargs:"test $projectName" -returntargetcode -filter:$coverageFilter -hideskipped:all -output:coverage.xml -log:Verbose
    }

    codecov -f "coverage.xml" -X gcov
  }
}
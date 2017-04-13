function pushToMyGet
{
  param(
    [parameter(Mandatory=$true)]
    [String]
    $parentFolder,
    [parameter(Mandatory=$true)]
    [String]
    $filePattern,
    [parameter(Mandatory=$true)]
    [String]
    $feedName,
    [parameter(Mandatory=$true)]
    [String]
    $apiKey
  )
  process
  {
    $matchingFiles = Get-ChildItem $parentFolder -recurse -Filter $filePattern

    Write-Host "Found" $matchingFiles.Count "files matching pattern '"$filePattern"' in folder '"$parentFolder"'"

    If ($matchingFiles.Count -eq 0) {
      Write-Host "No files match pattern, aborting."
      return
    }

    Write-Host "Using API key with length" $apiKey.Length

    if ($apiKey.Length -eq 0) {
      Write-Host "API key has length 0, aboring."
      return
    }

    $matchingFiles | Foreach-Object {
      $directory = [io.path]::GetDirectoryName($_.FullName)
      $fullpath = [io.path]::Combine($directory, $_)

      Write-Host "Now publishing" $fullpath

      $targetFeed = "https://www.myget.org/F/" + $feedName + "/api/v2/package"

      If ($_ -match "\.symbols\.") {
        $targetFeed = "https://www.myget.org/F/" + $feedName + "/symbols/api/v2/package"
      }

      nuget push $fullpath $apiKey -Source $targetFeed
    }
  }
}
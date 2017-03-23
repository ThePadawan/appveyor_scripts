function pushToMyGet($parentFolder, $filePattern, $envKeyApiKey)
{
  Write-Host "pushToMyGet"

  $matchingFiles = Get-ChildItem $parentFolder -recurse -Filter $filePattern

  Write-Host "Found" $matchingFiles.Count "files matching pattern '"$filePattern"' in folder '"$parentFolder"'"

  If ($matchingFiles.Count -eq 0) {
    Write-Host "No files match pattern, aborting."
    return
  }

  $matchingEnvKeys = Get-ChildItem Env: | Where-Object {$_.Name -eq $envKeyApiKey}

  if ($matchingEnvKeys.Count -eq 0) {
    Write-Host "Could not find Environment variable for MyGet feed at name" $envKeyApiKey "'"
    return
  }

  $apiKey = $matchingEnvKeys[0].Value
  Write-Host "Found API key with length" $apiKey.Length

  $matchingFiles | Foreach-Object {
    $directory = [io.path]::GetDirectoryName($_.FullName)
    $fullpath = [io.path]::Combine($directory, $_)

    Write-Host "Now publishing" $fullpath

    $targetFeed = "https://www.myget.org/F/the_diary/api/v2/package"

    If ($_ -match "\.symbols\.") {
      $targetFeed = "https://www.myget.org/F/the_diary/symbols/api/v2/package"
    }

    nuget push $fullpath $apiKey -Source $targetFeed
  }
}
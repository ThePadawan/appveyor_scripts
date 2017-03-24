function installCoverageTools
{
  process
  {
    nuget install OpenCover -Version 4.6.519
    nuget install dotnet-test-xunit -Pre -Version 2.2.0-preview2-build1029
    pip install codecov
  }
}
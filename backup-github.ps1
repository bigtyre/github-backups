# Get the token and username
$authToken = Get-Content .token
$username = Get-Content .username

$backupsDir = './backups'

if (!(Test-Path $backupsDir)) {
  New-Item -ItemType 'directory' $backupsDir
}

$backupsDir = $backupsDir | Resolve-Path

Write-Output "Backing up repositories to ${backupsDir}"

# Get the list of repositories
Write-Output "Fetching repository list from GitHub"
$response = Invoke-WebRequest -Uri "https://api.github.com/orgs/bigtyre/repos" -Headers @{ Authorization = "token $authToken" } 
$repositories = $response.Content
#$repositories = Get-Content repositories.json

# Get the clone url and name for each repository
Write-Output "Extracting git URLs"
$regexResult = Select-String -Pattern 'clone_url":\s*"([^"]+)"' -AllMatches  -inputobject $repositories 
$regexResult.Matches | ForEach-Object { 
  $url = $_.Groups[1].Value 
  $url -match "([A-Za-z0-9\-_.]+)\.git" | Out-Null
  $repositoryName = $Matches.1
  $repositoryDir = $repositoryName
  $bundleName = "${repositoryName}.bundle"
  $urlWithAuth = $url -replace "https://", "https://${username}:${authToken}@"

  # Remove existing repository directory if it exists
  if (Test-Path $repositoryDir) {
    Remove-Item -Force -Recurse $repositoryDir
  }

  Write-Output @{ Url = $url; Name = $repositoryName; UrlWithAuth = $urlWithAuth; BundleName = $bundleName } 

  git clone --mirror $urlWithAuth $repositoryDir
  Set-Location $repositoryDir
  git bundle create $bundleName --all
  Move-Item -Force $bundleName $backupsDir
  Set-Location ..

  # Remove directory if possible
  if (Test-Path $repositoryDir) {
    Remove-Item -Force -Recurse $repositoryDir
  }
  break
}
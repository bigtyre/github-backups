./backup-github.ps1

$targetDir = '\\bigtyre\files\Backups\Git Repositories'
New-Item -Force -Type Directory $targetDir
Copy-Item -Force -Recurse ./backups/* $targetDir
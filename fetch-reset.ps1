# Repo path
$repositoryPath = "C:\Framework4"

Set-Location -Path $repositoryPath

git fetch origin

# Reset local to match remote main
git reset --hard origin/main
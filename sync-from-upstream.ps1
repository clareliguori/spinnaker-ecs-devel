# sync repos from upstream
# to be run in /spinnaker directory

Get-ChildItem -Path ./ -Directory | ForEach-Object {
    cd $_
    echo $_
    git checkout master
    git pull --rebase upstream master
    git push origin
    cd ..
}
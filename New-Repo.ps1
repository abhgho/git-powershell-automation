
function New-Repo {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        $RepoName,
        [Parameter(Mandatory = $true)]
        $UserName,
        $ConfigFile = "C:\Users\abhik\Documents\dev-env\powershell\GitAutomation\config" ## Default config file location
    )


    ##### Read Github Access Token #####
    $fileContent = Get-Content -Path $ConfigFile
    $accessToken = ''

    foreach ($line in $fileContent) {
        if ($line.Contains('PERSONAL_ACCESS_TOKEN')) {
            $accessToken = $line -replace ".*="
        }
    }

    ##### Prepare Github API Post call #####
    $user = $UserName
    $pass = $accessToken
    $pair = "$($user):$($pass)"
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
    $basicAuthValue = "Basic $encodedCreds"
    $Headers = @{
        Authorization = $basicAuthValue
    }
    $body = @{
        name    = $RepoName
        accept  = 'application/vnd.github.v3+json'
        private = $false
    }

    $bodyJson = ConvertTo-Json $body
    Write-Output "Posting Data: "$bodyJson
    $response = Invoke-WebRequest -Method 'POST' -Uri 'https://api.github.com/user/repos' -Headers $Headers -Body $bodyJson
    $responseJson = $response | ConvertFrom-Json

    Write-Output "Repo : $($responseJson.html_url) Created!"

    ##### Create local repo and sync remote #####

    Write-Output "Creating local repo..."
    git init
    New-Item -Path .\README.MD ## POWERSHELL
    git add README.MD
    git commit -m 'initial commit -setup with powershell script'

    Write-Output "Syncing remote..."
    git remote add origin "$($responseJson.html_url).git"
    git push --set-upstream origin master

    Write-Output "DONE!"
}


$fileContent = Get-Content -Path .\config
$accessToken = ''
$repoName = $args[0]

foreach($line in $fileContent){
    if($line.Contains('PERSONAL_ACCESS_TOKEN')){
        $accessToken = $line.Substring(22)
    }
}

$user = 'abhgho'
$pass = $accessToken

$pair = "$($user):$($pass)"

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}
$body = @{
    name = $repoName
    accept = 'application/vnd.github.v3+json'
    private = $false
}

$bodyJson = ConvertTo-Json $body

Write-Host "Posting Data: "$bodyJson

$response = Invoke-WebRequest -Method 'POST' -Uri 'https://api.github.com/user/repos' -Headers $Headers -Body $bodyJson

$responseJson = $response | ConvertFrom-Json

Write-Host $responseJson.html_url" >>> Created!"
Write-Host "DONE!"
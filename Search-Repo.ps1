$fileContent = Get-Content -Path .\config
$accessToken = ''
$searchKey = $args[0]

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

$response = Invoke-WebRequest -Uri 'https://api.github.com/users/abhgho/repos' -Headers $Headers

$responseJson = $response | ConvertFrom-Json

foreach($item in $responseJson){
    if($item.full_name.Contains($searchKey)){
        Write-Host $item.full_name
    }
}
# Get the domain and forest functional levels
$domainFunctionalLevel = (Get-ADDomain).DomainMode
$forestFunctionalLevel = (Get-ADForest).ForestMode

Write-Host "Domain Functional Level: $domainFunctionalLevel"
Write-Host "Forest Functional Level: $forestFunctionalLevel"
"`n `r"

# Get all domain controllers
$domainControllers = Get-ADDomainController -Filter *

# Array to store domain controller information
$dcArray = @()

# Iterate through each domain controller
foreach ($dc in $domainControllers) {
    $domain = $dc.Domain
    $dcName = $dc.Name
    $operatingSystem = $dc.OperatingSystem
    $operatingSystemVersion = $dc.OperatingSystemVersion

    # Create a hashtable for domain controller information
    $dcInfo = @{
        "Domain Controller" = $dcName
        "Name" = $domain
        "Operating System" = $operatingSystem
        "Operating System Version" = $operatingSystemVersion
    }

    # Add the hashtable to the array
    $dcArray += [PSCustomObject]$dcInfo
}

# Get the maximum potential functional level for each domain
$domains = Get-ADDomain
$maxLevelArray = @()

foreach ($domain in $domains) {
    $domainName = $domain.Name
    $maxPotentialFunctionalLevel = $domain.DomainMode

    # Create a hashtable for domain information
    $domainInfo = @{
        "Name" = $domainName
        "CurrentLevel" = $domainFunctionalLevel
        "MaxPotentialFunctionalLevel" = $maxPotentialFunctionalLevel
    }

    # Add the hashtable to the array
    $maxLevelArray += [PSCustomObject]$domainInfo
}

# Get the maximum potential functional level for the forest
$forest = Get-ADForest
$forestName = $forest.Name
$maxPotentialForestFunctionalLevel = $forest.ForestMode

$forestInfo = @{
    "Name" = $forestName
    "CurrentLevel" = $forestFunctionalLevel
    "MaxPotentialFunctionalLevel" = $maxPotentialForestFunctionalLevel
}

$maxLevelArray += [PSCustomObject]$forestInfo

Write-Host "Forest: $forestName"
Write-Host "Max Potential Forest Functional Level: $maxPotentialForestFunctionalLevel"

$check = Read-Host "Export to CSV? (Press Enter path to export, or type 'n' to skip)"

if ($check -ne "n") {
    If(!(Test-Path -Path $check)) {
        $maxLevelArray | Export-Csv -Path C:\temp\ForestDomain.csv -NoTypeInformation
        Write-Host "Bad path.....CSV exported to 'C:\temp'" -ForegroundColor Red    
    } Else {
        $maxLevelArray | Export-Csv -Path $check\ForestDomain.csv -NoTypeInformation
        Write-Host "CSV file exported successfully '$check'" -ForegroundColor Green
    }
}
else {
    $maxLevelArray | Export-Csv -Path C:\temp\ForestDomain.csv -NoTypeInformation
    Write-Host "CSV exported to 'C:\temp\'" -ForegroundColor Cyan
}


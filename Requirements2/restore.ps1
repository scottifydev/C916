function Create-OU {
    New-ADOrganizationalUnit -Name finance -ProtectedFromAccidentalDeletion $false
    
    $NewAD = Import-Csv $PSScriptRoot\financePersonnel.csv
    $Path = 'ou=finance,DC=ucertify,DC=com'
    foreach ($ADUser in $NewAD) {
    
        $First = $ADUser.First_Name
        $Last = $ADUser.Last_Name
        $Name = $First, $Last -join ' ' 
        $Postal = $ADUser.PostalCode
        $Office = $ADUser.OfficePhone
        $Mobile = $ADUser.MobilePhone
    
        New-AdUser -GivenName $First -Surname $Last -Name $Name -PostalCode $Postal -OfficePhone $Office -MobilePhone $Mobile -Path $Path
        
    }
}
function Create-Database {
    Import-Module -Name sqlps -DisableNameChecking
    $ServerName = '.\UCERTIFY3'
    $Srv = New-Object Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerName
    $Database = 'ClientDB'
    $DB = New-Object Microsoft.SqlServer.Management.Smo.Database -ArgumentList $Srv,$Database
    $DB.Create()
    
    Invoke-Sqlcmd -ServerInstance $ServerName -Database $Database -InputFile $PSScriptRoot\schema.sql
    
    $Table = 'dbo.Client_A_Contacts'
    
    Import-Csv $PSScriptRoot\NewClientData.csv | ForEach-Object { `
        Invoke-Sqlcmd -ServerInstance $ServerName -Database $Database -Query `
        "INSERT INTO $Table (first_name, last_name,city, county,zip, officePhone, mobilePhone) `
        VALUES ('$($_.first_name)','$($_.last_name)','$($_.city)','$($_.county)','$($_.zip)','$($_.officePhone)','$($_.mobilePhone)'`
        )"`
    }
}

function Write-ADResults {
    Get-ADUser -Filter * -SearchBase 'ou=finance,dc=ucertify,dc=com' -Properties DisplayName,PostalCode,OfficePhone,MobilePhone > .\AdResults.txt
}
function Write-SqlResults {    
    Invoke-Sqlcmd -Database ClientDB -ServerInstance .\UCERTIFY3 -Query 'SELECT * FROM dbo.Client_A_Contacts' > .\SqlResults.txt
}



try {
    Clear-Host
    Write-Host 'Restoring Finance Organizational Unit...'
    Create-OU
    Write-Host 'Restoring Client Database...'
    Create-Database
    Set-Location $PSScriptRoot
    Write-Host 'Writing file AdResults.txt...'
    Write-ADResults
    Write-Host 'Writing file SqlResults.txt...'
    Write-SqlResults
 }
 catch [System.OutOfMemoryException] {
     "System encountered an Out of Memory Exception"
 }
 
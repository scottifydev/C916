 

# B.  Write a single script within the “restore.ps1” file that performs all of the following functions without user interaction:

function Remove-OU ($OUName) {
    $Identity =  "ou=",$OUName,",DC=ucertify,DC=com" -join ''
    Remove-ADOrganizationalUnit -Identity $Identity -Recursive
}
function Create-OU {
    New-ADOrganizationalUnit -Name finance -ProtectedFromAccidentalDeletion $false
    
    $NewAD = Import-Csv $PSScriptRoot\financePersonnel.csv
    $Path = "ou=finance,DC=ucertify,DC=com"
    foreach ($ADUser in $NewAD) {
    
        $First = $ADUser.First_Name
        $Last = $ADUser.Last_Name
        $Name = $ADUser.First_Name, $ADUser.Last_Name -join ' ' 
        $Postal = $ADUser.PostalCode
        $Office = $ADUser.OfficePhone
        $Mobile = $ADUser.MobilePhone
    
        New-AdUser -Name $Name -GivenName $First -Surname $Last -PostalCode $Postal -OfficePhone $Office -MobilePhone $Mobile -Path $Path
        
    }
}
$option = Read-Host 'Select an option'
switch ($option) {
    1 { Create-OU }
    2 { 
        $OUName = Read-Host 'Enter an OU name to Remove'
        Remove-OU ($OUName)
    }
    3 {
        #Get a server object which corresponds to the default instance  
        cd \sql\localhost\  
        $srv = get-item default  
        Write-Host $srv
        #Create a new database  
        # $db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -argumentlist $srv, "Test_SMO_Database"  
        # $db.Create()  
          
        # #Reference the database and display the date when it was created.   
        # $db = $srv.Databases["Test_SMO_Database"]  
        # $db.CreateDate  
          
        # #Drop the database  
        # $db.Drop()  

    }
}





# 3.  Create a new database on the UCERTIFY3 SQL server instance called “ClientDB.”

# 4.  Create a new table and name it “Client_A_Contacts.” Add this table to your new database.

# 5.  Insert the data from the attached “NewClientData.csv” file (found in the “Requirements2” folder) into the table created in part B4.
 

# C.  Apply exception handling using try-catch for System.OutOfMemoryException.
 

# D.    Run the script within the uCertify environment. After the script executes successfully, run the following cmdlets individually from within your Requirements2 directory:
# 1. Get-ADUser -Filter * -SearchBase “ou=finance,dc=ucertify,dc=com” -Properties DisplayName,PostalCode,OfficePhone,MobilePhone > .\AdResults.txt
# 2. Invoke-Sqlcmd -Database ClientDB –ServerInstance .\UCERTIFY3 -Query ‘SELECT * FROM dbo.Client_A_Contacts’ > .\SqlResults.txt



# Note: Ensure you have all of the following files intact within the “Requirements2” folder, including the original files:

# •  “restore.ps1”

# •  “AdResults.txt”

# •  “SqlResults.txt”
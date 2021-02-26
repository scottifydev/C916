# Scott Lee - 001397458

# Clearing screen for a nice application look
Clear-Host

# Begining Try/Catch block.

try {

    # Creating prompt text in a variable
    $prompt = "EEP1 TASK 1: SCRIPTING IN POWERSHELL`n`rEnter a number 1-5 to Select From the Following Tasks`n`r1: Update DailyLog.txt`n`r2: Update C916contents.txt`n`r3: View Proccessor Time & Memory Usage`n`r4: View System Processes`n`r5: Exit`n`r"

    # A function to rewrite the screen after user input. Takes Variable from the switch since it is outside of the scope of the switch input variable
    function Run-Task ($TaskNumber) {
        Write-Host "Running Task $TaskNumber ..."
        Start-Sleep -Seconds 1.5
        Clear-Host
        Write-Host "Task $TaskNumber Complete!`n`r"
    }

    # Do-Until loop to cycle through user inputs

    do {
        
        # Switch with user input for task number

        $input = Read-Host $prompt 
        switch ($input) {
            
            # 1. On user input of "1", Add-Content cmdlet add a String with the current date using Get-Date and all of the .log files in the current directory using Get-ChildItem and formatted into a readable table, and outputted as a string. New contents are appended to the tail of the DailyLog.txt without destroying the existing contents. The Run-Task function is executed and passes along to input variable.
            
            1 {
                Add-Content -Path $PSScriptRoot\DailyLog.txt -Value "Log files for: $(Get-Date)`n`r$(Get-ChildItem *.log | Format-Table -AutoSize | Out-String)"
                $(Run-Task $input)
            }
            
            # 2. On user input of "2", Set-content creates or overwrites the contents fo C916contents.txt using the Get-Child cmdlet. The contents are formatted into a readable table with Format-Table. The Run-Task function is executed and passes along to input variable.
            
            2 {
                Set-Content -Path $PSScriptRoot\C916contents.txt -Value (Get-ChildItem $PSScriptRoot\* | Format-Table -AutoSize | Out-String)
                $(Run-Task $input)
            }
            
            # On user input of "3", the screen is cleared and the user is notified that the script is measuring system performance. The Get-Counter cmdlet measures 4 samples of the Processor Time and Commited Memory at 5 second intervals and displays them with a prompt for the user to continue. The screen is cleared and the main prompt brought back up. 
            
            3 {
                Clear-Host
                Write-Host 'Measuring System Performance...'
                Get-Counter -Counter "\Processor(_Total)\% Processor Time", "\Memory\Committed Bytes" -SampleInterval 5 -MaxSamples 4
                read-host 'Press Enter to continue'
                Clear-Host
                
            }
            
            # 4.  On user input of "4", the powershell grid view window is opened displaying all running processes sorted by CPU time in decending order. The script waits for the window to be closed before proceeding. Screen is cleared and user is reprompted for input.
            
            4 {
                Write-Host "Close Process List to Continue." -ForegroundColor Yellow
                Get-Process | Sort-Object CPU -desc | Out-GridView -Wait
                Clear-Host
            }

            # 5.  On user input of "5", the screen is cleared and the user is notified that the script is terminating. The Do until loop is fulfilled and the program exits.
            
            5 {
                Clear-Host 
                Write-Host "Exiting..."
            }

            # On any input that doesn't match any of the switch cases, the user is prompted to make a valid entry.
            
            Default {
                Clear-Host
                Write-Error "Please Make a Valid Entry" 
            }
        }
    } 

    # The until clause of Do loop is defined when the user inputs "5" to close end the script.

    until ($input -eq '5')

 }

# Catch function for System Out of Memory Error notifies user of exception and that the script is exiting.

 catch [System.OutOfMemoryException] {
     Write-Host "`n`rAn System Out of Memory Error occurred.`n`r" -ForegroundColor red
     Write-Host "Exiting... `n`r"
 }

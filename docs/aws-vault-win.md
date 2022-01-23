# Installing AWS-Vault on Windows

If you are familiar with Microsoft Windows Administration, you may install AWS-Vault using your preferred method.  However, if you are not familiar with Windows Administration it is recommended that you follow the instructions below.

**Disclaimer:** These instructions are designed to work on Windows 10 and later.  You should note that each PowerShell box provided below is a single command.

1.	Open PowerShell with Administrators Rights

    a.	Click Start (Windows Icon on the taskbar)

    b.	Type 'PowerShell'  (do not include the quotation marks)

    c.	Press and hold [Shift]+[Control] on the keyboard and then press [Enter]

    d.	If prompted type the Administrator Password and click 'Yes' (depending on your configuration you may not be prompted type give authorization to allow PowerShell to amend your system configuration).

    e.	Check that the title bar of your PowerShell windows, includes the word 'Administrator' in it.


2.	Download AWS-Vault from GitHub <https://github.com/99designs/aws-vault/releases/download/v6.4.0/aws-vault-windows-386.exe>

```powershell
Invoke-WebRequest -Method Get -Uri https://github.com/99designs/aws-vault/releases/download/v6.4.0/aws-vault-windows-386.exe -OutFile $env:Userprofile\Downloads\aws-vault.exe
```

3.	Create a new folder named ‘aws-vault’ in your ‘Program Files x86’ folder (The default path is C:\Program Files (x86).
```powershell
New-Item -Path ${env:ProgramFiles(x86)} -Name aws-vault -ItemType Directory
```

4.	Rename the executable file in step 1 to '**aws-vault**', then move the downloaded executable from your downloads folder to the newly created folder.
```powershell
Move-Item -Path ${env:UserProfile}\Downloads\aws-vault.exe -Destination ${env:ProgramFiles(x86)}\aws-vault\aws-vault.exe -Force
```
 
5.	Configure your system wide Path Variable to include the newly created folder.
```powershell
[Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";${env:ProgramFiles(x86)}\aws-vault", [EnvironmentVariableTarget]::Machine) 
```

6.	Reboot your machine
```powershell
Restart-Computer -ComputerName $env:COMPUTERNAME -Force
```

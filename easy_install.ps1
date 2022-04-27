<#
   This script attmpts to simplify the install process
   for face_recognition that many users have on Windows.
   It centers around using the package manager Chocolatey
   which makes the requirement install substantially
   easier.
#>


<#
   this try-catch block checks if Chocolatey is installed,
   if it is, it simply attemps to upgrade itself. If it is
   not installed, it installs it in the catch block. Once
   the try-catch segment is over, the requirement, dlib,
   and face_recognition packages are installed
#>

function Attempt-Command($command) {
   Try {
      if ($command){
         Write-Output "$command is installed"
      }
   }
   Catch {
      Write-Output "Installing $command..."
      choco install $command -y
      Install-Dependencies
   }
}

function Attempt-Cmake {
   Try {   
      if (cmake) {
         Write-Output "cmake is installed"
      }
   }
   Catch {
      choco install cmake --installargs '"ADD_CMAKE_TO_PATH=System"' -y
      Install-Dependencies
   }
}

function Install-Dependencies {
   Attempt-Command python3
   Attempt-Command pip
   Attempt-Cmake
   RefreshEnv.cmd

   # Proceed with the quick install process for face_recognition
   pip install dlib
   pip install face_recognition
}
Try {
   if(choco){
      choco upgrade chocolatey -y
   }
}
Catch {
   # Save the original execution policy for the current user
   $originalExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser

   # Change the current user's execution policy to 'RemoteSigned'.
   # This allows for the execution of the Chocolatey install script
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

   # Find the download script for the Chocolatey install script
   $script = New-Object Net.WebClient
   $script.DownloadString("https://chocolatey.org/install.ps1")

   # iwr is short for 'Invoke-WebRequest'. It installs sends an
   # HTTP/HTTPS request for the link, downloading Chocolatey's
   # 'install.ps1'. iex (Invoke-Expression) then executes it
   iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

   # reset the current user's execution policy
   Set-ExecutionPolicy -Scope CurrentUser $originalExecutionPolicy
}
Finally {
   # Chocolatey can now install requirements (python3, cmake, and dlib)
   # if they're not already installed. If they are, then Chocolatey
   # automatically skips over it.
   Install-Dependencies
}
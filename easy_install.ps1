<#
   This script attempts to simplify the install process
   for face_recognition that many users have on Windows.
   It centers around using the package manager Chocolatey
   which makes installing the requirements substantially
   easier.
#>

<#
   this try-catch block checks if Chocolatey is installed,
   if it is, it simply attempts to upgrade itself. If it is
   not installed, it installs it in the catch block. Once
   the try-catch segment is over, the requirement, dlib,
   and face_recognition packages are installed
#>
Try {
   if(choco){
      choco upgrade chocolatey
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
   Set-ExecutionPolicy -Scope CurrentUser
   $originalExecutionPolicy
}
Finally {
   # Chocolatey can now install requirements (python3, cmake, and dlib)
   # if they're not already installed. If they are, then Chocolatey
   # automatically skips over it.
   choco install -y python3 cmake pip

   pip install dlib
   pip install face_recognition
}
# Only install when building for 32bit
Function InstallMSYS32 {
	Write-Host "Installing MSYS2 32-bit..." -ForegroundColor Cyan

	# download installer
	$zipPath = "$($env:USERPROFILE)\msys2-i686-latest.tar.xz"
	$tarPath = "$($env:USERPROFILE)\msys2-i686-latest.tar"
	Write-Host "Downloading MSYS installation package..."
	(New-Object Net.WebClient).DownloadFile('http://repo.msys2.org/distrib/msys2-i686-latest.tar.xz', $zipPath)

	Write-Host "Untaring installation package..."
	7z x $zipPath -y -o"$env:USERPROFILE" | Out-Null

	Write-Host "Unzipping installation package..."
	7z x $tarPath -y -oC:\ | Out-Null
	del $zipPath
	del $tarPath
}

# The Rtools 32 it installer cannot be installed on AppVeyor (win64) so we use the zip file
Function InstallRTOOLS32 {
	Write-Host "Installing RTOOLS 32-bit..." -ForegroundColor Cyan
	$zipPath = "$($env:USERPROFILE)\rtools32.7z"
	(New-Object Net.WebClient).DownloadFile('https://dl.bintray.com/rtools/installer/rtools40-i686.7z', $zipPath)
	7z x $zipPath -y -oC:\ | Out-Null
	C:\rtools40\usr\bin\bash.exe --login -c exit 2>$null
	Write-Host "InnoSetup installation: Done" -ForegroundColor Green
}

Function InstallRTOOLS64 {
	Write-Host "Installing RTOOLS 64-bit..." -ForegroundColor Cyan
	(New-Object Net.WebClient).DownloadFile('https://dl.bintray.com/rtools/installer/rtools40-x86_64.exe', '..\installer.exe')
	Start-Process -FilePath ..\installer.exe -ArgumentList /SILENT -NoNewWindow -Wait
	Write-Host "InnoSetup installation: Done" -ForegroundColor Green
}

function bash($command) {
    Write-Host $command -NoNewline
    cmd /c start /wait C:\rtools40\usr\bin\sh.exe --login -c $command
    Write-Host " - OK" -ForegroundColor Green
}

function bootstrap {
	if($env:MSYS_VERSION -eq 'msys32') {
		InstallRTOOLS32
	} else {
		InstallRTOOLS64
	}
	bash 'pacman -Sy --noconfirm pacman pacman-mirrors'
	bash 'pacman -Syyuu --noconfirm --ask 20'
}


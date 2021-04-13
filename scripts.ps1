### Global variables
$RTOOLS_ARCH = ${env:RTOOLS_ARCH}
$RTOOLS_ZIP = "rtools40-${RTOOLS_ARCH}.7z"
$RTOOLS_EXE = "rtools40-${RTOOLS_ARCH}.exe"
#$ErrorActionPreference = "Stop";

### Use for bootstrapping installation
# $RTOOLS_MIRROR = "https://dl.bintray.com/rtools/installer/"
$RTOOLS_MIRROR = "https://ftp.opencpu.org/archive/rtools40/"
# $RTOOLS_MIRROR = "https://ftp.opencpu.org/archive/rtools/4.0/"

### InnoSetup Mirror
$INNO_MIRROR = "https://github.com/jrsoftware/issrc/releases/download/is-5_6_1/innosetup-5.6.1-unicode.exe"
# $INNO_MIRROR = "https://mlaan2.home.xs4all.nl/ispack/innosetup-5.6.1-unicode.exe"
# $INNO_MIRROR = "http://files.jrsoftware.org/is/5/innosetup-5.6.1-unicode.exe"

function CheckExitCode($msg) {
  if ($LastExitCode -ne 0) {
    Throw $msg
  }
}

# Unzip and Initiate Rtools dump
Function InstallRtoolsZip {
	Write-Host "Installing ${RTOOLS_ZIP}..." -ForegroundColor Cyan
	$tmp = "$($env:USERPROFILE)\${RTOOLS_ZIP}"
	(New-Object Net.WebClient).DownloadFile($RTOOLS_MIRROR + $RTOOLS_ZIP, $tmp)
	7z x $tmp -y -oC:\ | Out-Null
	CheckExitCode "Failed to extract ${RTOOLS_ZIP}"
	C:\rtools40\usr\bin\bash.exe --login -c exit 2>$null
	Write-Host "Installation of ${RTOOLS_ZIP} done!" -ForegroundColor Green
}

# Don't use installer when: (1) architecture doesn't match host (2) Dir C:/rtools40 already exists
Function InstallRtoolsExe {
	Write-Host "Installing ${RTOOLS_EXE}..." -ForegroundColor Cyan
	$tmp = "$($env:USERPROFILE)\${RTOOLS_EXE}"	
	(New-Object Net.WebClient).DownloadFile($RTOOLS_MIRROR + $RTOOLS_EXE, $tmp)
	Start-Process -FilePath $tmp -ArgumentList /VERYSILENT -NoNewWindow -Wait
	CheckExitCode "Failed to install ${RTOOLS_EXE}"
	Write-Host "Installation of ${RTOOLS_EXE} done!" -ForegroundColor Green
}

function bash($command) {
    Write-Host $command -NoNewline
    cmd /c start /wait C:\rtools40\usr\bin\sh.exe --login -c $command
    Write-Host " - OK" -ForegroundColor Green
}

function InstallRtools {
	InstallRtoolsZip
	bash 'pacman -Sy --noconfirm pacman pacman-mirrors'
	bash 'pacman -Syu --noconfirm --ask 20'		
}

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

Function UpdateMSYS2 {
	C:\msys64\usr\bin\pacman --noconfirm -Sy
	C:\msys64\usr\bin\pacman --noconfirm --needed -S msys2-runtime msys2-runtime-devel mintty
	C:\msys64\usr\bin\pacman --noconfirm --needed -S bash pacman
}

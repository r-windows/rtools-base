@echo off
set PATH=%~dp0;%PATH%
echo Executing: texindex %*...
%~dp0\bash /usr/bin/texindex %*

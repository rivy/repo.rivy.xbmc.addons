@echo off
@setlocal

:: URLref: http://kodi.wiki/view/Add-on_repositories @@ https://archive.is/e8MOa
:: URLref: http://kodi.wiki/view/HOW-TO:Create_a_repository_for_add-ons @@ https://archive.is/W6Ox1

set __ME=%~n0
set __ME_path=%~dp0.
set __ME_temp_path=_build

if EXIST "%__ME_path%\%__ME_temp_path%" ( rmdir /s/q "%__ME_path%\%__ME_temp_path%" )
mkdir "%__ME_path%\%__ME_temp_path%"

::

:: Update script.audio.pandora from github repo
set NAME=script.audio.pandora
set ID=R-v2.3.2
set V=2.3.2
set USER=rivy
set PREFIX=xbmc-
:
if NOT DEFINED V ( set "V=%ID%" )
call :$github_pull_and_process "%NAME%" "%ID%" "%V%" "%USER%" "%PREFIX%"
if NOT "%ERRORLEVEL%" == "0" ( echo %__ME%: $github_pull_and_process failed & exit /b -1 )


:: Update repository.rivy.xbmc from github repo
set NAME=repository.rivy.xbmc
set ID=master
set V=1.0.0
set USER=rivy
set PREFIX=xbmc-
:
if NOT DEFINED V ( set "V=%ID%" )
call :$github_pull_and_process "%NAME%" "%ID%" "%V%" "%USER%" "%PREFIX%"
if NOT "%ERRORLEVEL%" == "0" ( echo %__ME%: $github_pull_and_process failed & exit /b -1 )

::

rmdir /s/q "%__ME_path%\%__ME_temp_path%"

echo %__ME%: Generating addons.XML with MD5
call addons_gen.BAT

goto :EOF

#### SUBs

::
:$github_pull_and_process ( XBMC_NAME COMMIT_ID VERSION USER [PREFIX] )
:: NOTE: must use wget/curl, as github forbids git archive --remote=...
:: NOTE: github.com URL template for zip archive download is https://github.com/%USER%/%REPO%/archive/%COMMIT_ID%.zip
@setlocal
set "NAME=%~1"
set "ID=%~2"
set "V=%~3"
set "USER=%~4"
set "PREFIX=%~5"
set "ROUTE=%USER%/%PREFIX%"

echo %__ME%: Downloading %NAME% (%ID%) archive
curl -# -L -o "%__ME_path%\%__ME_temp_path%\%NAME%-%ID%.zip" "https://github.com/%ROUTE%%NAME%/archive/%ID%.zip"
if NOT EXIST "%__ME_path%\%__ME_temp_path%\%NAME%-%ID%.zip" ( echo %__ME%: ERROR: Unable to download archive & exit /b -1 )
echo %__ME%: Extracting archive
if EXIST "%__ME_path%\%__ME_temp_path%\%NAME%-%ID%" ( rmdir /s/q "%__ME_path%\%__ME_temp_path%\%NAME%-%ID%" )
unzip -q "%__ME_path%\%__ME_temp_path%\%NAME%-%ID%.zip" -d "%__ME_path%\%__ME_temp_path%"
if EXIST "%__ME_path%\%__ME_temp_path%\%NAME%" ( rmdir /s/q "%__ME_path%\%__ME_temp_path%\%NAME%" )
rename "%__ME_path%\%__ME_temp_path%\%PREFIX%%NAME%-%ID%" "%NAME%"
if NOT EXIST "%NAME%" ( mkdir "%NAME%" )
if NOT EXIST "%__ME_path%\%__ME_temp_path%\%NAME%"\addon.xml ( echo %__ME%: ERROR: Archive is missing addon.xml & exit /b -1 )
xcopy /y "%__ME_path%\%__ME_temp_path%\%NAME%"\addon.xml "%NAME%" 1>NUL
if NOT EXIST "%__ME_path%\%__ME_temp_path%\%NAME%"\icon.png ( echo %__ME%: ERROR: Archive is missing icon.png & exit /b -1 )
xcopy /y "%__ME_path%\%__ME_temp_path%\%NAME%"\icon.png "%NAME%" 1>NUL
if NOT EXIST "%__ME_path%\%__ME_temp_path%\%NAME%"\changelog.txt ( echo %__ME%: ERROR: Archive is missing changelog.txt & exit /b -1 )
copy /y "%__ME_path%\%__ME_temp_path%\%NAME%"\changelog.txt "%NAME%\changelog-%V%.txt" 1>NUL
if NOT EXIST "%__ME_path%\%__ME_temp_path%\%NAME%"\fanart.jpg ( goto :_gpap_COPY_DONE )
xcopy /y "%__ME_path%\%__ME_temp_path%\%NAME%"\fanart.jpg "%NAME%" 1>NUL
:_gpap_COPY_DONE
echo %__ME%: Building final zip archive
if EXIST "%__ME_path%\%NAME%\%NAME%-%V%.zip" ( erase "%__ME_path%\%NAME%\%NAME%-%V%.zip" 1>NUL )
cd "%__ME_path%\%__ME_temp_path%"
zip -9qr -o "%__ME_path%\%NAME%\%NAME%-%V%.zip" "%NAME%"
:_gpap_ZIP_DONE

goto :EOF
::

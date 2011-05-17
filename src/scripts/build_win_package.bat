
:: Before running this script ensure that the %PATH% has the location of:
::    - the correct qmake for the Qt to build against
::    - the compiler and build tools, eg nmake
::         for these first two, use the C:\Qt\<ver>\bin\qtvars.bat vsvars command
::    - NSIS compiler, "makensis"
::         set PATH=%PATH%;"C:\Program Files (x86)\NSIS"
::         NSIS needs the custom license plugin - if its not installed get it
::         from http://nsis.sourceforge.net/CustomLicense_plug-in
::    - The perl interpreter "perl.exe" - this is required anyway for building qt
:: Run this script from the root of a complete source tree of Qt3D, eg
::    mkdir C:\build\qt
::    cd C:\build\qt
::    mkdir quick3d_mk_win_pkg
::    echo .git >exclude
::    xcopy /EXCLUDE:exclude /S C:\depot\qt\quick3d quick3d_mk_win_pkg
::    cd quick3d_mk_win_pkg
::    src\scripts\build_win_package.bat

:: Use jom if possible - put jom in the path if you want faster compiles
where jom.exe
if %ERRORLEVEL% NEQ 0 (
    SET MAKE_PRG=nmake
) else (
    SET MAKE_PRG=jom
)

qmake -query QT_VERSION >tmp\qt_version
set /P QT_VERSION= <tmp\qt_version

:: On windows if the qt3d.prf and qt3dquick.prf exist in the Qt, the build will fail
:: with impenetrable link errors.  This should not happen but might if you are trying
:: to debug the installer scripts, and do something odd.
del %QTDIR%\mkspecs\features\qt3d*

qmake.exe quick3d.pro -spec win32-msvc2008 CONFIG+=release CONFIG+=package

:: This has to be the full path, but without the drive letter...
set INSTALL_ROOT=%CD:~2%\tmp
%MAKE_PRG% install
%MAKE_PRG% docs
perl -pi.bak -e "s/#VER#/%QT_VERSION%/g" src\scripts\run_start_program.bat
makensis /DQT_VERSION=%QT_VERSION% /NOCD src\scripts\build_win_package.nsi

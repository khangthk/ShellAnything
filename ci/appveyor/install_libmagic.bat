@echo off

:: Validate appveyor's environment
if "%APPVEYOR_BUILD_FOLDER%"=="" (
  echo Please define 'APPVEYOR_BUILD_FOLDER' environment variable.
  exit /B 1
)

:: libmagic is a C library with a C api.
:: We do not have any plans on debugging the library,
:: so compiling in Debug mode is not required for this project.
:: Because the C api provides binary compatibility, this library
:: can be safely compiled in Release mode while ShellAnything
:: and other modules are compiled in Debug mode.
::
:: Forcing Configuration=Release for this build.
::

set LIBMAGIC_ROOT=%APPVEYOR_BUILD_FOLDER%\third_parties\libmagic
set LIBMAGIC_DIR=%LIBMAGIC_ROOT%\install

set PCRE2_ROOT=%LIBMAGIC_ROOT%\pcre2
set PCRE2_INSTALL_DIR=%PCRE2_ROOT%\install_dir

echo ============================================================================
echo Cloning libmagic into %APPVEYOR_BUILD_FOLDER%\third_parties\libmagic
echo ============================================================================
mkdir %APPVEYOR_BUILD_FOLDER%\third_parties >NUL 2>NUL
cd %APPVEYOR_BUILD_FOLDER%\third_parties
@REM git clone --recurse-submodules "https://github.com/julian-r/file-windows" libmagic
git clone --recurse-submodules "https://github.com/Cirn09/file-windows" libmagic
cd libmagic
echo.

@REM echo Checking out version 5.38...
@REM git -c advice.detachedHead=false checkout v5.38
@REM echo.

echo ============================================================================
echo Generating PCRE2...
echo ============================================================================
cd /d %PCRE2_ROOT%
mkdir build >NUL 2>NUL
cd build
cmake -Wno-dev -DCMAKE_GENERATOR_PLATFORM=%Platform% -T %PlatformToolset% -DCMAKE_INSTALL_PREFIX="%PCRE2_INSTALL_DIR%" -DCMAKE_PREFIX_PATH="%APPVEYOR_BUILD_FOLDER%\third_parties\zlib\install" ..
if %errorlevel% neq 0 exit /b %errorlevel%

echo ============================================================================
echo Compiling PCRE2...
echo ============================================================================
cd /d %PCRE2_ROOT%\build
cmake --build . --config Release
if %errorlevel% neq 0 exit /b %errorlevel%

 ============================================================================
echo Installing PCRE2 into %PCRE2_INSTALL_DIR%
echo ============================================================================
cd /d %PCRE2_ROOT%\build
cmake --install . --config Release
if %errorlevel% neq 0 exit /b %errorlevel%
echo.

echo ============================================================================
echo Generating libmagic...
echo ============================================================================
cd /d %LIBMAGIC_ROOT%
mkdir build >NUL 2>NUL
cd build
cmake -Wno-dev -DCMAKE_GENERATOR_PLATFORM=%Platform% -T %PlatformToolset% -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=%CONFIGURATION% -DCMAKE_INSTALL_PREFIX="%libmagic_DIR%" -DCMAKE_PREFIX_PATH="%PCRE2_INSTALL_DIR%;%APPVEYOR_BUILD_FOLDER%\third_parties\zlib\install" ..
if %errorlevel% neq 0 exit /b %errorlevel%

echo ============================================================================
echo Compiling libmagic...
echo ============================================================================
cmake --build . --config Release
if %errorlevel% neq 0 exit /b %errorlevel%
echo.

echo ============================================================================
echo Installing libmagic into %libmagic_DIR%
echo ============================================================================
cmake --install . --config Release
if %errorlevel% neq 0 exit /b %errorlevel%
echo.

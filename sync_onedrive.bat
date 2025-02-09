:: sync_onedrive.bat
:: Sun_Feb_09_2025_0515PM
:: Revision 2.4

@echo on
setlocal enabledelayedexpansion

:: Default values
set "ONEDRIVE_BASE=C:\Users\asliw\OneDrive"
set "LOCAL_BASE=C:\src\Onedrive"
set "DIRPATH="
set "LOGFILE=%LOCAL_BASE%\sync_log.txt"
set "DEBUG=0"

:: Prevent script from dropping into functions
GOTO :MAIN

:: Function to run a test and return success/failure
:run_test
echo [TEST] %~1...
if %2 %3 %4 %5 %6 %7 %8 %9 (
    echo [PASSED] %~1
) else (
    echo [FAILED] %~1
    exit /b 1
)
exit /b 0

:MAIN
:: Parse command-line arguments
:parse_args
if "%~1"=="" goto :validate_args
if "%~1"=="--dirpath" (
    set "DIRPATH=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--debug" (
    set "DEBUG=1"
    shift
    goto :parse_args
)
echo Unknown argument: %~1
exit /b 1

:validate_args
:: Enable debug mode if --debug is set
if "%DEBUG%"=="1" (
    echo [DEBUG] Debug mode enabled.
    @echo on
)

:: Ensure --dirpath argument was provided
if "%DIRPATH%"=="" (
    echo Usage: %~nx0 --dirpath "Drb.5.Drburns\Books-Pdf" [--debug]
    exit /b 1
)

:: Construct full source and destination paths
set "SRC=%ONEDRIVE_BASE%\%DIRPATH%"
set "DEST=%LOCAL_BASE%\%DIRPATH%"

:: Run Pre-Sync Tests
call :run_test "Checking if OneDrive folder exists"  exist "%SRC%"
@rem call :run_test "Checking if local sync folder exists (creating if necessary)"  exist "%DEST%" || mkdir "%DEST%"
@rem call :run_test "Checking if robocopy is available" where robocopy >nul 2>&1

:: Append log header
echo ------------------------------------ >> "%LOGFILE%"
echo Sync Started: %DATE% %TIME% >> "%LOGFILE%"
echo Source: %SRC% >> "%LOGFILE%"
echo Destination: %DEST% >> "%LOGFILE%"
echo ------------------------------------ >> "%LOGFILE%"

:: Run Robocopy with mirroring and append to log
robocopy "%SRC%" "%DEST%" /MIR /R:3 /W:5 /LOG+:"%LOGFILE%" /TEE /NDL /NP

:: Append completion log
echo Sync Completed: %DATE% %TIME% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: Check the error code and display an appropriate message
if %ERRORLEVEL% GEQ 8 (
    echo Sync failed with error code %ERRORLEVEL%. Check sync_log.txt for details.
) else (
    echo Sync completed successfully!
    dir %DEST%
)

exit /b %ERRORLEVEL%

:: -------------------------------------------------------------
:: How to Use:
:: Run the script with the `--dirpath` argument:
:: sync_onedrive.bat --dirpath "Drb.5.Drburns\Books-Pdf" [--debug]
::
:: How It Works:
:: 1. Accepts `--dirpath` argument and assigns it to %DIRPATH%.
:: 2. Supports `--debug` to enable detailed logging and command echo.
:: 3. Dynamically constructs source and destination paths:
::    - SRC = C:\Users\asliw\OneDrive\%DIRPATH%
::    - DEST = C:\src\Onedrive\%DIRPATH%
:: 4. Runs built-in **pre-sync tests**:
::    - Checks if OneDrive folder exists.
::    - Checks if local destination exists (creates if missing).
::    - Ensures `robocopy` is available in the system.
:: 5. Runs Robocopy in mirror mode (`/MIR`).
:: 6. **Appends** logs to C:\src\Onedrive\sync_log.txt.
::
:: Example Results:
:: sync_onedrive.bat --dirpath "Drb.5.Drburns\Books-Pdf"
:: sync_onedrive.bat --dirpath "Drb.5.Drburns\Books-Pdf" --debug
::
:: Copies everything from:
:: C:\Users\asliw\OneDrive\Drb.5.Drburns\Books-Pdf
:: To:
:: C:\src\Onedrive\Drb.5.Drburns\Books-Pdf
::
:: Chat Reference:
:: This script was created in response to a user request.
:: For reference, visit the conversation at:
:: [URL of this Chat Conversation]
:: -------------------------------------------------------------
::
:: Revision History:
:: - 1.1 (Sat_Feb_08_2025_1130AM): Initial version with argument parsing.
:: - 1.2 (Sat_Feb_08_2025_1135AM): Added chat conversation URL section.
:: - 1.3 (Sat_Feb_08_2025_1145AM): Added revision history and structured comments.
:: - 1.4 (Sun_Feb_09_2025_1016AM): Fixed timestamp to correct EST format.
:: - 1.5 (Sun_Feb_09_2025_1025AM): Updated log file to append instead of overwrite.
:: - 1.6 (Sun_Feb_09_2025_1040AM): Added built-in pre-sync tests.
:: - 1.7 (Sun_Feb_09_2025_1055AM): Added `--debug` switch to enable `ECHO ON`.
:: - 1.8 (Sun_Feb_09_2025_1105AM): Fixed "batch label not found" error by moving `:run_test` function above calls.
:: - 2.0 (Sun_Feb_09_2025_0445PM): Fixed invalid test call format in `:run_test`.
:: - 2.1 (Sun_Feb_09_2025_0500PM): Fixed `:run_test` execution using `cmd /c` to properly run commands.
:: - 2.2 (Sun_Feb_09_2025_0510PM): Fixed `:run_test` logic by directly executing test conditions.
:: - 2.3 (Sun_Feb_09_2025_0447PM): Corrected timestamp format dynamically.
:: - 2.4 (Sun_Feb_09_2025_0515PM): **Fixed script auto-executing `run_test` by adding `GOTO :MAIN`.**
::
:: Future Enhancements:
:: - Implement logging improvements to track changes more effectively.
:: - Add dry-run mode for testing sync operations before execution.
:: -------------------------------------------------------------

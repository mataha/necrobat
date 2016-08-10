@echo off
:: necrobat.bat - a simple batch script for NecroBot
:: Copyright (C) 2016  Mataha  <mataha@users.noreply.github.com>
:: 
:: This program is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
:: 
:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
:: 
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.

setlocal EnableExtensions EnableDelayedExpansion
set "_script_author=Mataha"
set "_script_name=%~n0"
set "_script_version=1.1"

:: Installation note: drop this file into the bot directory and run this
:: script, either by double-clicking it or from the command line.

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: +--------------------------------------------------------------------------+
:: |                             Global variables                             |
:: +--------------------------------------------------------------------------+

set "_script_extension=%~x0"
set "_script_file=%_script_name%%_script_extension%"

:: This script assumes that your directory tree looks as follows:
::
::   .
::   +---Config\
::   +---NecroBot.exe
::   +---[this script]
::
:: You should modify the following variables if your dirtree varies.
set "_bot_dir=."
set "_bot_extension=.exe"
set "_bot_name=NecroBot"

set "_bot_binary=%_bot_name%%_bot_extension%"
set "_bot_path=%~dp0%_bot_dir%"

set "_bot=%_bot_path%\%_bot_binary%"

:: Extension used during renaming old files while updating.
set "_renamed_extension=.old"
set "_renamed_script_file=%_script_file%%_renamed_extension%"
set "_renamed_script=%~dp0%_renamed_script_file%"

set /A "_TIME_MINUTE=60"
set /A "_TIME_HOUR=60*%_TIME_MINUTE%"

:: +--------------------------------------------------------------------------+
:: |                         Public global variables                          |
:: +--------------------------------------------------------------------------+

::@ Success return code (`0` by convention).
set /A "_EXIT_SUCCESS=0"

::@ General failure return code (`1` by convention).
set /A "_EXIT_FAILURE=1"

::@ Time between bot restarts. Used to check if there's an update; serves
::@   as a sanity check against uncaught exceptions in the binary as well.
::@   Set to an hour by default.
set /A "_necrobat_restart_delay=%_TIME_HOUR%"

:: +--------------------------------------------------------------------------+
:: |                             Inline functions                             |
:: +--------------------------------------------------------------------------+

set "botkill=taskkill /F /IM "%_bot_binary%" /T >nul 2>&1"

set "reset_title=title %ComSpec%>nul 2>&1"

::@ An idiom for `timeout >nul 2>&1 /NOBREAK /T`.
::@
::@  param %1  the length of time to sleep in seconds
::@
set "sleep=timeout >nul 2>&1 /NOBREAK /T"

:: +--------------------------------------------------------------------------+
:: |                         Public inline functions                          |
:: +--------------------------------------------------------------------------+

::@ Pretty prints a string.
::@
::@  param %*  the string to output
::@
set "necrobat_echo=echo [%_script_name%]"

::@ Sets the command prompt's title to a default value and exits the script.
::@   The argument serves as a status code. By convention, a zero status code
::@   indicates a successful execution; a nonzero status code indicates an
::@   abnormal termination. This function doesn't return normally; anything
::@   after this call is a dead code. 
::@
::@  param %1  exit status
::@
set "necrobat_exit=%reset_title%& exit /B"

::@ Kills every instance of this bot.
::@
set "necrobat_kill=%botkill%"

::@ Renames this script, stripping the `.old` extension caused by an update.
::@
set "necrobat_rename=rename "%_renamed_script%" "%_script_file%" >nul 2>&1"

::@ Sleeps for an amount of time specified by `%necrobat_restart_delay%`.
::@
set "necrobat_sleep=%sleep% "%_necrobat_restart_delay%" || goto error"

::@ Starts the bot in background. Sets the command prompt's title to a non-nul
::@   value in order to avoid the nul-title job bug. Wish there was a better
::@   way of doing this, but cmd.exe's job control is really, REALLY poor.
::@   Not to mention NecroBot needs an access to the console because muh
::@   non-blocking key reader inside an infinite loop. Cute, deshou~?
::@
set "necrobat_start=start "%_bot%" /B %_bot% || goto error"

::@ Stops the bot.
::@
::@  impl_note Calls `%necrobat_kill%`.
::@
set "necrobat_stop=%necrobat_kill% || goto error"

::@ Displays this script's usage.
::@
set "necrobat_usage=%necrobat_echo% Usage: %_script_name%"

:: +--------------------------------------------------------------------------+
:: |                                 Handlers                                 |
:: +--------------------------------------------------------------------------+

set "_handler_arg=__ExitHandlerRegistered"

::@ A primitive TRAP implementation - terminates every bot running
::@   in the background and exits. Acts as a simple exit handler.
::@
if "_%~1" equ "_" (
  set "ERRORLEVEL="
  cmd /U /C "%~f0" %_handler_arg% %*
  
  set /A "_RC=%_EXIT_FAILURE%&%ERRORLEVEL%"
  set /A "_RC|=%_EXIT_SUCCESS%"
  
  %necrobat_echo% Terminating every %_bot_name% instance...
  %necrobat_kill%
  %necrobat_echo% Terminated every %_bot_name% instance successfully.
  
  %necrobat_echo% Exiting main script...
  %necrobat_exit% %_RC%
) else (
  if "_%~1" neq "_%_handler_arg%" (
    %necrobat_echo% This script doesn't support command line options.
    %necrobat_echo% The following options have been supplied: '%*'
    %necrobat_usage%
    
    %necrobat_exit% %_EXIT_FAILURE%
  )
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Main loop.
:main

%necrobat_echo% %_script_name% %_script_version% - written by %_script_author%
%necrobat_echo% Initializing...

:: Cleanup after update. This has to be done before the infinite loop.
if exist "%_script_file%" erase /Q "%_renamed_script_file%" >nul 2>&1

:forever

%necrobat_echo% Starting %_bot_name%...
%necrobat_start%
%necrobat_echo% %_bot_name% started successfully^^!

%necrobat_echo% Going to sleep...
%necrobat_sleep%
%necrobat_echo% Waking up...

%necrobat_echo% Restarting %_bot_name%...
%necrobat_stop%
%necrobat_echo% Terminated the previous %_bot_name% instance.

:: In case of a really, REALLY unexpected update.
:: By the way, AutoUpdate setting should be set to false as of 0.4.0+!
%necrobat_rename% && %necrobat_echo% Detected an update - renamed the script.

:: End of main loop.
goto forever

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Error handler.
:error

%necrobat_echo% Fatal error - something went totally wrong^^! >&2

:: Return control to the parent script.
%necrobat_echo% Unwinding... >&2
%necrobat_exit% %_EXIT_FAILURE% >&2

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: There is no way to nicely reset the text color, so we might be stuck
:: with a leftover color from the bot. Nothing we can do about it.
:EOF

::~charlimit:79

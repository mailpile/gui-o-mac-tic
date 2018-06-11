-- Executes a 'command' in a new Terminal.app Window, and sets that Window's active Tab's title to 'title'.
--
-- This script solves a problem with the following, commonly suggested, naive solution:
--
-- tell application "Terminal"
--     do script foobar
-- end tell
--
-- Namely the problem that if Terminal.app is not already running, 'do script foobar' opens a second
-- Window as if the user had has explicitly opened Terminal.app.

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

set command to "COMMAND_TOKEN"
set title to "TITLE_TOKEN"

set terminal_app_was_running_when_this_script_began_execution to application "Terminal" is running
tell application "Terminal"
    set tab_id to null
    set thewindow to null
    set terminal_app_has_at_least_one_open_window to exists window 0
    if terminal_app_has_at_least_one_open_window then
        if terminal_app_was_running_when_this_script_began_execution then
            set tab_id to do script command
        else -- 'tell application "Terminal"' launched Terminal.app
            set tab_id to do script command in first window
        end if
        set thewindow to first window of (every window whose tabs contains tab_id)
    else -- Terminal.app is running but all of it's Windows are closed.
        set tab_id to do script "" -- Create a new Tab (thereby a new Window) and remember that Tab's ID.
        set thewindow to first window of (every window whose tabs contains tab_id) -- Get Tab's Window.
        do script command in thewindow -- Execute 'command' in the Window's active Tab.
    end if
    set custom title of tab_id to title -- Set the Tab's title.
    activate -- Makes Terminal.app the frontmost application.
    return id of thewindow
end tell



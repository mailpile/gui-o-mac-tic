-- Closes all Terminal.app Windows/Tabs whose id is in ids_of_windows_to_close.

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

set ids_of_windows_to_close to {WINDOW_IDS_TOKEN}

tell application "Terminal"
    repeat with window_id in ids_of_windows_to_close
        try
            close first window of (every window whose id is window_id)
        end try
    end repeat
end tell

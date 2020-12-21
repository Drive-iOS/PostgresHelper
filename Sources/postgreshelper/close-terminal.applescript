on run (windowID)
	tell application "Terminal"
        # Close window with passed in windowID
		close (every window whose id is windowID)
		delay 2

        # Move Terminal window to foreground
        activate
        delay 2

        # Click on confirm button for closing Terminal
		tell application "System Events"
			click UI element "Terminate" of sheet 1 of window 1 of application process "Terminal"
		end tell
	end tell
end run

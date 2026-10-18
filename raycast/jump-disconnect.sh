#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jump Desktop: Disconnect
# @raycast.mode silent
# @raycast.packageName Jump Desktop
# @raycast.icon ❌

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "computer (blank = all sessions)", "optional": true }

# Jump has no AppleScript dictionary, so this closes session windows via System Events
# (File > Close Window on the raised session window), then restores the previous frontmost app.
# Raycast needs Accessibility permission (System Settings > Privacy & Security > Accessibility).
# Session windows are titled with the computer's name; the library window is "Jump Desktop".

osascript - "$1" "${JUMP_DRY_RUN:-}" "${JUMP_EXACT:-}" <<'EOF'
on run argv
  set target to item 1 of argv
  set dryRun to (item 2 of argv is not "")
  set exactMatch to (item 3 of argv is not "")
  set closed to {}
  tell application "System Events"
    if not (exists process "Jump Desktop") then return "Jump isn't running"
    set prevApp to first application process whose frontmost is true
    tell process "Jump Desktop"
      repeat with w in (reverse of (get windows))
        set t to name of w
        if t is not "Jump Desktop" and (target is "" or (exactMatch and t is target) or (not exactMatch and t contains target)) then
          if not dryRun then
            -- Session windows are borderless (no close button), so raise and use File > Close Window.
            perform action "AXRaise" of w
            set frontmost to true
            delay 0.1
            click menu item "Close Window" of menu 1 of menu bar item "File" of menu bar 1
            delay 0.2
          end if
          set end of closed to t
        end if
      end repeat
    end tell
    -- Closing raises Jump, so hand focus back to whatever was in front before.
    if not dryRun and (count of closed) > 0 and name of prevApp is not "Jump Desktop" then
      set frontmost of prevApp to true
    end if
  end tell
  if (count of closed) is 0 then return "No matching session"
  set AppleScript's text item delimiters to ", "
  if dryRun then return "Would disconnect: " & (closed as text)
  return "Disconnected: " & (closed as text)
end run
EOF

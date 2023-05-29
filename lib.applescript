(*
AppleScript utility handlers
A drop-in library of modern AppleScript utility functions

Version 0.1
APL 2.0
*)

-- Compile AppleScript
-- Perform compilation on .AppleScript file to make it into a binary
on compileAppleScript(sourcePath, destPath)
    set shellCommand to "osacompile -o " & destPath & " " & sourcePath
    try
        do shell script shellCommand
    on error errMsg number errNum
        display dialog "An error occurred: " & errMsg & " (Error " & errNum & ")"
    end try
end compileAppleScript

-- Macintosh-flavor paths
-- Convert between classic macintosh-style and unix-style paths, and vice-versa
on convertPathToUnixStyle(macPath)
    try
        set oldDelims to AppleScript's text item delimiters
        set AppleScript's text item delimiters to ":"
        set pathItems to text items of macPath
        set AppleScript's text item delimiters to "/"
        set unixPath to "/" & pathItems as text
        set AppleScript's text item delimiters to oldDelims
        return unixPath
    on error errMsg number errNum
        display dialog "An error occurred: " & errMsg & " (Error " & errNum & ")"
    end try
end convertPathToUnixStyle

on convertPathToMacStyle(unixPath)
    try
        set oldDelims to AppleScript's text item delimiters
        set AppleScript's text item delimiters to "/"
        set pathItems to text items of unixPath
        set AppleScript's text item delimiters to ":"
        set macPath to pathItems as text
        set AppleScript's text item delimiters to oldDelims
        return macPath
    on error errMsg number errNum
        display dialog "An error occurred: " & errMsg & " (Error " & errNum & ")"
    end try
end convertPathToMacStyle

-- Get file or folder size
-- Use Finder to get the size of a file or folder, as an integer
on getSize(itemPath)
    try
        tell application "Finder"
            get size of (POSIX file itemPath as alias)
        end tell
    on error errMsg
        display dialog "Error getting size of the item: " & errMsg
    end try
end getSize

-- Read file
-- Safely read from a file
on readTextFile(filePath)
    try
        set fileContent to read file filePath as text
    on error errMsg number errNum
        display dialog "Error reading file: " & filePath & return & "Error Message: " & errMsg & " | Error Number: " & errNum
        return ""
    end try
    return fileContent
end readTextFile

-- Write to file
-- Safely write content to a text file, with an option to either overwrite or append to an existing file's contents
on writeTextToFile(content, filePath, overwrite)
    try
        set fileDescriptor to open for access file filePath with write permission
        if overwrite is true then
            set eof of fileDescriptor to 0 -- if overwrite is true, reset the end of file marker to 0
        end if
        write content to fileDescriptor starting at eof -- write content, if overwrite is false, it will start at eof and append
        close access fileDescriptor
    on error errMsg
        display dialog "Error writing to file: " & errMsg
        try
            close access file filePath
        end try
    end try
end writeTextToFile

-- Delete file
-- Either move a file to trash or skip the trash, deleting it permanently
on deleteItem(itemPath, permanent)
    try
        if permanent is true then
            do shell script "rm " & quoted form of POSIX path of itemPath
        else
            tell application "Finder"
                delete POSIX file itemPath
            end tell
        end if
    on error errMsg
        display dialog "Error deleting item: " & errMsg
    end try
end deleteItem

-- Create notification
on showNotification(title, message)
    if title is not "" and message is not "" then
        try
            display notification message with title title
        on error errMsg
            display dialog "Failed to display notification: " & errMsg
        end try
    else
        display dialog "Error: Both title and message must be non-empty strings."
    end if
end showNotification

-- Timer
-- Display a timed dialog box, setting a timer in seconds
on displayTimedDialog(message, seconds)
    try
        if seconds < 0 then error "Negative time is not valid"
        display dialog message giving up after seconds
    on error errMsg
        display dialog "Error displaying timed dialog: " & errMsg
    end try
end displayTimedDialog

-- Set volume
-- Set system volume as a 0 to 100 integer value
on setVolume(level)
    try
        if level < 0 or level > 100 then error
        set volume output volume level
    on error
        display dialog "Error: Invalid volume level. Please enter a number between 0 and 100."
    end try
end setVolume

-- Open URL
-- Open an address in the default browser, or specify a browser
on openURL(url, browser)
    try
        if browser is "" or browser is missing value then
            -- use default browser
            tell application "System Events"
                open location url
            end tell
        else
            -- use custom browser
            tell application browser
                open location url
            end tell
        end if
    on error errMsg
        display dialog "Error opening URL: " & errMsg
    end try
end openURL

-- Set desktop background
on setDesktopPicture(filePath)
    try
        tell application "Finder"
            set desktop picture to POSIX file filePath
        end tell
    on error errMsg
        display dialog "Error setting desktop picture: " & errMsg
    end try
end setDesktopPicture

-- Eject all external disks
on ejectAllDisks()
    try
        tell application "Finder"
            eject (every disk whose ejectable is true)
        end tell
    on error errMsg
        display dialog "Error ejecting disks: " & errMsg
    end try
end ejectAllDisks

-- Set custom sleep
on setSleepSettings(displaySleepMinutes, diskSleepMinutes)
    try
        do shell script "sudo pmset displaysleep " & displaySleepMinutes & " disksleep " & diskSleepMinutes with administrator privileges
    on error errMsg
        display dialog "Error setting sleep settings: " & errMsg
    end try
end setSleepSettings

-- Quit all apps
on quitAllApps()
    try
        tell application "System Events"
            set allApps to name of every application process whose background only is false
            repeat with appName in allApps
                tell application appName to quit
            end repeat
        end tell
    on error errMsg
        display dialog "Error quitting apps: " & errMsg
    end try
end quitAllApps

-- Return the current wifi network
on getCurrentWiFi()
    try
        do shell script "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}'"
    on error errMsg

-- Convert image
-- Convert an image into another image, changing the types, most often used to convert HEIC to PNG or JPG
on convertImage(sourcePath, destinationPath, format)
    try
        if format is not in {"jpeg", "png"} then error "Invalid format. Please specify 'jpeg' or 'png'."
        do shell script "sips -s format " & format & " " & quoted form of sourcePath & " --out " & quoted form of destinationPath
    on error errMsg
        display dialog "Error converting image: " & errMsg
    end try
end convertImage

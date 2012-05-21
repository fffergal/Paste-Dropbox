on clipboardType()
	set usableTypes to {"PNGf", "RTF ", "utf8", "furl"}
	set clipTypes to {}
	repeat with clip in clipboard info
		set clipTypes to clipTypes & {the first item of clip}
	end repeat
	repeat with clipType in clipTypes
		repeat with usableType in usableTypes
			if clipType as text is equal to "Çclass " & usableType & "È" then
				return usableType
			end if
		end repeat
	end repeat
	return ""
end clipboardType

on clipboardData(theType)
	set clip to the clipboard as theType
	if theType as text is "furl" then
		set theFile to open for access clip
		return read theFile as data
	else if (theType as text is "RTF ") then
		set tmpuuid to do shell script "uuidgen"
		set theFile to (open for access ("/tmp/" & tmpuuid) with write permission)
		write clip to theFile
		close access theFile
		set html to do shell script "textutil -convert html /tmp/" & tmpuuid & "  -stdout"
		tell application "System Events"
			delete file ("/tmp/" & tmpuuid)
		end tell
		return html
	else
		return clip
	end if
end clipboardData

on list_position(this_item, this_list)
	repeat with i from 1 to the count of this_list
		if item i of this_list is this_item then return i
	end repeat
	return 0
end list_position

on clipboardExtension(theType)
	set theType to theType as text
	set staticTypes to {"PNGf", "RTF ", "utf8"}
	set staticExtensions to {".png", ".html", ".txt"}
	if staticTypes contains theType then
		return item (list_position(theType, staticTypes)) of staticExtensions
	else if theType is equal to "furl" then
		return "." & name extension of (info for (the clipboard as "furl"))
	else
		return ""
	end if
end clipboardExtension

on typesDebug()
	set debug to ""
	repeat with info in clipboard info
		set debug to debug & "
" & (first item of info as string)
	end repeat
	display alert debug
end typesDebug

on getDropboxNumber()
	try
		set fromDefaults to do shell script "defaults read com.me8b.pastedropbox DropboxNumber"
		if fromDefaults is not equal to "" then return fromDefaults
	on error
		set fromDialog to text returned of (display dialog "What is your Dropbox number? (This can be found by looking at the URLs dropbox makes for your public files. eg http://dl.dropbox.com/u/<your number here>/Some-image.png)" default answer "")
		do shell script "defaults write com.me8b.pastedropbox DropboxNumber -string " & fromDialog
		return fromDialog
	end try
end getDropboxNumber

on run
	--typesDebug()
	set dropboxFolder to do shell script "echo `tail -n 1 .dropbox/host.db` | openssl enc -d -a"
	set dropboxNumber to getDropboxNumber()
	set uuid to do shell script "uuidgen"
	set theType to clipboardType()
	if theType is not "" then
		set theData to clipboardData(theType)
		set theExtension to clipboardExtension(theType)
		set theFile to (open for access ((POSIX path of (path to home folder as text)) & "Dropbox/Public/" & uuid & theExtension) with write permission)
		write theData to theFile
		set the clipboard to "http://dl.dropbox.com/u/" & dropboxNumber & "/" & uuid & theExtension
	end if
end run
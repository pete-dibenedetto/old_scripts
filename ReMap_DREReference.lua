function handler(document)

	
	--The purpose of this script is to set AUTN:TITLE to DREREFERENCE if <autn:title> No Slide Title </autn:title>.
	local 	AutnLinkField = document:findField("LINK")
	local 	AutnLink = document:fieldGetValue(AutnLinkField)
	
	local 	DreRef = document:findField("DREREFERENCE")

	document:fieldSetValue (DreRef,AutnLink)
	
	

       return true

		
	end
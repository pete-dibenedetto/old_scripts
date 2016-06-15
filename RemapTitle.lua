function handler(document)

	
	--The purpose of this script is to set AUTN:TITLE to DREREFERENCE if <autn:title> No Slide Title </autn:title>.
	local 	AutnTitleField = document:findField("JOB_TITLE")
	local 	AutnTitle = document:fieldGetValue(AutnTitleField)
	
	local 	JobTitle = document:findField("DRETITLE")

	document:fieldSetValue (JobTitle,AutnTitle)
	
	

       return true

		
	end
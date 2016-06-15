function handler(config, document, params )
	log("CFSFilter.log", "Entering CFSFilter")
	
	-- Enter in values for searching
	local searchDateFrom = '03012013'
	local searchDateTo = '04012013'
	local searchExtractTo = 'fhlmc@fhlmc'
	local searchFolder = 'Archive'

	--local docDate = document:getFieldValue("CREATETIME_NUMERICDATE")

	local docDate = document:getFieldValue("MessageDate")
	 	
	log("CFSFilter.log", "Have our date")
	log("CFSFilter.log", docDate)
 
	local ConvertedDateFrom = convert_date_time(searchDateFrom,"MMDDYYYY","EPOCHSECONDS")
	local ConvertedDateTo =  convert_date_time(searchDateTo,"MMDDYYYY","EPOCHSECONDS")

	log("CFSFilter.log", "Converted From Date -->")
	log("CFSFilter.log", ConvertedDateFrom)

	log("CFSFilter.log", "Converted To Date -->")
	log("CFSFilter.log", ConvertedDateTo)

	if docDate then

	if (ConvertedDateFrom == nil) and (ConvertedDateTo == nil) then
	
	return true

	elseif (docDate >= ConvertedDateFrom)and (docDate <= ConvertedDateTo) then
	
	log("CFSFilter.log", "Entering Good Date Check")
	log("CFSFilter.log", docDate)
	return true

	elseif (docDate < ConvertedDateFrom) or (docDate > ConvertedDateTo) then
		log("CFSFilter.log", "Entering Bad Date Check")
		log("CFSFilter.log", docDate)
	return false

	end
	end
end
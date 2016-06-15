function handler( document )
    identifier = document:getFieldValue( "AUTN_IDENTIFIER" )
    if identifier then
		indices = document:getFieldValue( "SubFileIndexCSV" )
		if indices then
			indices = string.gsub(indices, ",", ".")
			document:setFieldValue( "AUTN_IDENTIFIER", identifier .. "|" .. indices )
		end
	end
    return true
end
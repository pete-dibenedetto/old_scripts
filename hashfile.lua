function handler( document )
    md5val = document:getFieldValue("MD5")
    familymd5val = document:getFieldValue("FAMILYMD5")
    filename = document:getFieldValue("DREFILENAME")
    rootparentfilename = document:getFieldValue("DREROOTPARENTREFERENCE")
    
    if (not md5val or md5val == "") then
    	local hashValue = hash_file(filename,"MD5")
    	document:addField("MD5",hashValue)
    end
    
    if (not familymd5val or familymd5val == "") then
        local hashValue = hash_file(rootparentfilename,"MD5")
        document:addField("FAMILYMD5",hashValue)
    end
    
    return true
    
end

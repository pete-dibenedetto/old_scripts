function tagUsers(document,path)
    u = {"f350199","f352351","f254023","f359529","f237006","f144277","f353983","f251174","f351367","f190899","f196016","f351147"}
    taggedcustodian = false
    for i,v in ipairs(u) do
        local curValue = v
        if string.find(path,curValue) then
            taggedcustodian = true
            document:addField("DISCOVEREDCUSTODIANID",curValue)
        end
    end
    
    if (not taggedcustodian) then
    	document:addField("DISCOVEREDCUSTODIANID","Unregistered")
    end
end

function handler(document)
    path = document:getFieldValue("DREREFERENCE")
    tagUsers(document,path)
    return true
end
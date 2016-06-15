function striptags(s) 
    return utf2lat(s:gsub("</?[A-Za-z][A-Za-z0-9:_%-]*[^>]*>", " "):gsub("%s+", " ")) 
end 

function utf2lat(s) 
	
	local t = {}   
	local i = 1   
	while i <= #s do      
		local c = s:byte(i)      
		i = i + 1      
		if c < 128 then         
			table.insert(t, string.char(c))      
		elseif 192 <= c and c < 224 then         
			local d = s:byte(i)         
			i = i + 1         
			if (not d) or d < 128 or d >= 192 then 
				return nil, "UTF8 format error"         
			end         
			c = 64*(c - 192) + (d - 128)         
			table.insert(t, string.char(c))     
		else         
			table.insert(t, " ")
	
		end   
	end
	--log("ocs_ingest.log","utf2lat out = " .. table.concat(t))
	return table.concat(t)
end



function handler(document)

	local original_content = document:getFieldValue("DRECONTENT")

	local content = striptags(original_content);

	document:setFieldValue("DRECONTENT",content); 

	document:addField("NewTitle",content)
	
       return true

end

 

function handler(document)

	zpos = 0
	zneg = 0
	zmixed = 0
	zvibe = 0
	
    for _,zfield in ipairs{document:findField("POSITIVE_VIBE")}
    do
		zpos = zpos +1
		zvibe = zvibe +1
    end
	
    for _,zfield in ipairs{document:findField("NEGATIVE_VIBE")}
    do
		zneg = zneg +1 
		zvibe = zvibe - 1
    end
	
    for _,zfield in ipairs{document:findField("MIXED_VIBE")}
    do
		zmixed = zmixed +1
		zvibe = zvibe
    end
	
    if zvibe ~= 0 then
		if zvibe > 0 then 
			addFieldValues(document,"SENTIMENT","Positive")
			addFieldValues(document,"VIBE","Positive")
		else
			addFieldValues(document,"SENTIMENT","Negative")
			addFieldValues(document,"VIBE","Negative")
		end
	else
		if zmixed > 0 then
			addFieldValues(document,"SENTIMENT","Mixed")
			addFieldValues(document,"VIBE","Mixed")
		else
			addFieldValues(document,"SENTIMENT","Neutral")
			addFieldValues(document,"VIBE","Neutral")
		end
	end
	
end


function addFieldValues(document, field_name, field_value)
	_zfield = document:findField(field_name)
	if _zfield then
		document:fieldSetValue(_zfield,field_value);
	else
		document:addField(field_name,field_value);
	end
end


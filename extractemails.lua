-- extracts email addresses out of a specified field
function extract_email_addresses(document, fieldName)
	emails = document:getFieldValue(fieldName)
	if (emails) then
		fpat = ".-([%w%.%-_]+@[%w%.%-_]+).-"
		local s, e, cap = emails:find(fpat, 1)
		while s do
			if s ~= 1 or cap ~= "" then
				document:addField("EXTRACTED_" .. fieldName, string.lower(cap))
			end
			last_end = e+1
			s, e, cap = emails:find(fpat, last_end)
		end
	end
end

-- extracts email address domains out of a specified field
function extract_email_address_domains(document, fieldName)
	emails = document:getFieldValue(fieldName)
	if (emails) then
		fpat = ".-[%w%.%-_]+@([%w%.%-_]+).-"
		local s, e, cap = emails:find(fpat, 1)
		while s do
			if s ~= 1 or cap ~= "" then
				document:addField("EXTRACTED_DOMAIN_" .. fieldName, string.lower(cap))
			end
			last_end = e+1
			s, e, cap = emails:find(fpat, last_end)
		end
	end
end

function handler(document)
	extract_email_address_domains(document,"TO")
	extract_email_address_domains(document,"FROM")
	extract_email_address_domains(document,"CC")
	extract_email_address_domains(document,"BCC")
	extract_email_addresses(document,"TO")
	extract_email_addresses(document,"FROM")
	extract_email_addresses(document,"CC")
	extract_email_addresses(document,"BCC")
	extract_email_address_domains(document,"To")
	extract_email_address_domains(document,"From")
	extract_email_addresses(document,"To")
	extract_email_addresses(document,"From")
	return true
end

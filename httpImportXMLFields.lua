--Richard Lewis ,  parses XML file downloaded by HTTP connector, then uses XPaths to extract specific tags

function handler(document)

	local xPaths = {}
	xPaths[1]= {"NCT_ID","//id_info/nct_id","single"}
	xPaths[2]= {"OFFICIAL_TITLE","//official_title","single"}
	xPaths[3]= {"LEAD_SPONSOR","//lead_sponsor/agency","single"}
	xPaths[4]= {"COLLABORATOR","//collaborator/agency","multipleDeDup"}
	xPaths[5]= {"STUDY_TYPE","//study_type","single"}
	xPaths[6]= {"CONDITION","//condition","multipleDeDup"}
	xPaths[7]= {"INTERVENTION_TYPE","//intervention/intervention_type","multipleDeDup"}
	xPaths[8]= {"INTERVENTION_NAME","//intervention/intervention_name","multipleDeDup"}
	xPaths[9]= {"INTERVENTION_DESCRIPTION","//intervention/description","single"}
	xPaths[10]={"PHASE","//phase","multiple"}
	xPaths[11]={"START_DATE","//start_date","single"}
	xPaths[12]={"COMPLETED_DATE","//completion_date","single"}
	xPaths[13]={"BRIEF_SUMMARY","//brief_summary/textblock","single"}
	xPaths[14]={"DETAILED_DESCRIPTION","//detailed_description/textblock","single"}
	xPaths[15]= {"URL","//required_header/url","single"}
	xPaths[16]= {"OVERALL_STATUS","//overall_status","single"}
	
	
	xPaths[17]= {"PRIMARY_OUTCOME","//primary_outcome/measure","single"}
	xPaths[18]= {"SECONDARY_OUTCOME","//secondary_outcome/measure","multiple"}
	xPaths[19]= {"DRUG_NAME","//intervention[translate(intervention_type, 'DRUG', 'drug')='drug']/intervention_name","multipleDeDup"}
	xPaths[20]= {"ELIGIBILITY","//eligibility/criteria/textblock","single"}
	
	xPaths[21]= {"CONDITION_MESH","//condition_browse/mesh_term","multipleDeDup"}
	xPaths[22]= {"INTERVENTION_MESH","//intervention_browse/mesh_term","multipleDeDup"}
	xPaths[23]= {"CT_KEYWORD","/clinical_study/keyword","multiple"}
	
	xPaths[24]= {"COUNTRY","//location/facility/address/country","multipleDeDup"}
	xPaths[25]= {"CITY","//location/facility/address/city","multipleDeDup"}
	xPaths[26]= {"FACILITY","//location/facility/name","multiple"}
	
	
	local dreref = getSafeValue_CFS(document, "DREREFERENCE", "")
	
	local filepath = getSafeValue_CFS(document, "DREFILENAME", "")
	local content = getFileContent(filepath)
	if content then
		getXPaths(document,xPaths,content,dreref)
	else
		log("file content is nil for "..dreref)
	end
	
	return true
	
	
end



function getXPaths(document,xpaths,xmlContent,dreref)
	
	xmlContent = string.gsub(xmlContent,"<%?xml%-stylesheet .-%?>","")
	--xmlContent = string.gsub(xmlContent,"<%?xml .-%?>","<?xml ")
	--xmlContent = string.gsub(xmlContent,"<document .->","<document>")
	
	--log(xmlContent)

	local xmldoc = parse_xml(xmlContent)
	--e = xmldoc:XPathRegisterNs( "urn", "http://www.hl7.org/v3/voc" )
	--log("REGISTER "..e)
	if xmldoc then
		
		
		for k,v in pairs(xpaths) do
			if (v[3] == "single") then
				getSingleContent(document,xmldoc,v[2],v[1],dreref)
			elseif (v[3] == "multiple") then
				getMultipleContent(document,xmldoc,v[2],v[1],dreref)
			elseif (v[3] == "multipleDeDup") then
				getMultipleDeDupContent(document,xmldoc,v[2],v[1],dreref)					
			elseif (v[3] == "full") then
				getFullContent(document,xmldoc,v[2],v[1],dreref)
			elseif (v[3] == "multipleFull") then
				getMultipleFullContent(document,xmldoc,v[2],v[1],dreref)				
			else
				log("incorrect method specified for "..v[2].." for "..dreref)
			end
		end			
	else
		log("parse_xml  failed for "..dreref)
	end

end


function getSingleContent(document,xmldoc,xPath,fieldName,dreref)
	local xnodes = xmldoc:XPathExecute(xPath)
	if xnodes then
		if(xnodes:size() > 0) then
			document:addField(fieldName,xnodes:at(0):content())
		end
	else
		log("xpath "..xPath.."not found for "..dreref)
	end
end

function getMultipleContent(document,xmldoc,xPath,fieldName,dreref)
	local xnodes = xmldoc:XPathExecute(xPath)
	if xnodes then
		i = 0
		while (i < xnodes:size()) do
			--log(xnodes:at(i):nodePath())
			document:addField(fieldName,xnodes:at(i):content())
			i = i+1
		end
	else
		log("xpath "..xPath.."not found for "..dreref)
	end
end

function getMultipleDeDupContent(document,xmldoc,xPath,fieldName,dreref)
	local nodesFound = {}
	
	local xnodes = xmldoc:XPathExecute(xPath)
	if xnodes then
		i = 0
		while (i < xnodes:size()) do
			--log(xnodes:at(i):nodePath())
			if not(contains(nodesFound,xnodes:at(i):content())) then
				table.insert(nodesFound,xnodes:at(i):content())
				document:addField(fieldName,xnodes:at(i):content())
			end
			i = i+1
		end
	else
		log("xpath "..xPath.."not found for "..dreref)
	end
end

function getFullContent(document,xmldoc,xPath,fieldName,dreref)
	local xnodes = xmldoc:XPathExecute(xPath.."/descendant::text()")
	if xnodes then
		if (xnodes:size() > 0) then
			i = 0
			local fieldValue = ""
			while (i < xnodes:size()) do
				--log(xnodes:at(i):nodePath())
				fieldValue = fieldValue..xnodes:at(i):content()
				i = i+1
			end
			document:addField(fieldName,fieldValue)
		end
	else
		log("xpath "..xPath.."not found for "..dreref)
	end
end

function getMultipleFullContent(document,xmldoc,xPath,fieldName,dreref)
	local xnodes = xmldoc:XPathExecute(xPath)
	if xnodes then
		local i = 0
		while (i < xnodes:size()) do
			--log(xnodes:at(i):nodePath())
			local xp = xnodes:at(i):nodePath()
			getFullContent_NoLineBreaks(document,xmldoc,xp,fieldName,dreref)
			--document:addField(fieldName,xnodes:at(i):content())
			i = i+1
		end
	else
		log("xpath "..xPath.."not found for "..dreref)
	end
end

function getFullContent_NoLineBreaks(document,xmldoc,xPath,fieldName,dreref)
	log(xPath)
	local xnodes = xmldoc:XPathExecute(xPath.."/descendant::text()")
	if xnodes then
		if (xnodes:size() > 0) then
			local i = 0
			local fieldValue = ""
			while (i < xnodes:size()) do
				--log(xnodes:at(i):nodePath())
				local nodeValue = xnodes:at(i):content()
				nodeValue = string.gsub(nodeValue,"\n"," ")
				fieldValue = fieldValue..nodeValue
				i = i+1
			end
			document:addField(fieldName,trim5(cleanWhitespace(fieldValue)))
			log(trim5(fieldValue))
		else
			log("xnodes empty for "..xPath.." for "..dreref)
		end
	else
		log("xpath "..xPath.."not found for "..dreref)
	end
end
	
function getFileContent(filename)
	local fl, c = io.open(filename)
	if (c ~= nil) then
		log(c)
		return nil
	else
		local content = fl:read("*a")
		fl:close()
		return content
	end		
end	
	
	
function regexEscapeString(str)
	return string.gsub(str,"[%-%]%[%.%+%*%%%$%^]","%%%0")
end

function urlEncode (s)
  s = string.gsub(s, "([&=+%c])", function (c)
		return string.format("%%%02X", string.byte(c))
	  end)
  s = string.gsub(s, " ", "+")
  return s
end	
		
	
function trim5(s)
	return s:match'^%s*(.*%S)' or ''
end

function contains(t,s)
	for k,v in pairs(t) do
		if (v==s) then 
			return true
		end
	end
	return false
end		
	
function deepContains(t,s)
	if (type(t) ~= "table") then
		if (t==s) then
			return true
		end
	else
		for k,v in pairs(t) do
			if (deepContains(v,s)) then 
				return true
			end
		end
	end
	return false
end
	
	
function string.strsplit(delimiter, text)
  local list = {}
  local pos = 1
  if string.find("", delimiter, 1) then -- this would result in endless loops
    return nil
  end
  while 1 do
    local first, last = string.find(text, delimiter, pos)
    if first then -- found?
      table.insert(list, string.sub(text, pos, first-1))
      pos = last+1
    else
      table.insert(list, string.sub(text, pos))
      break
    end
  end
  return list
end	



function log(content)
	local f = io.open('logs\\lua.log', 'a')
	f:write(os.date() .. ' ' .. content .. '\n')
	f:close()
end

function getSafeValue_FSC(document,fieldname,default)
	local f = document:getFieldValue(fieldname)
	if f then
		return f
	else
		return default
	end
end

function getSafeValue_IT(document, fieldname, default)
	local f = document:findField(fieldname)
	if f then
	    return document:fieldGetValue(f)
	end
	return default
end

function getSafeValue_CFS(document, fieldname, default)
	local f = document:getFieldValue(fieldname)
	if f ~= nil then
	    return f
	end
	return default
end			
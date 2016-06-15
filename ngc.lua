-- ======================================================
-- Main Handler
-- ======================================================
function handler(document)

	-- fix %20 in reference
	local ref = getFieldValue(document,"DREREFERENCE")
	if ref and string.find(ref,"%20", 0, true) then
		ref = ref:gsub("%%20"," ");
		updateField(document, "DREREFERENCE", ref, "update")
	end
	
	--The purpose of this script is to set AUTN:TITLE to DREREFERENCE if <autn:title> No Slide Title </autn:title>.
	local AutnTitleField = getFieldValue(document,"autn:title")
	local DrereferenceContent = getFieldValue(document,"DREREFERENCE")
	if (not AutnTitleField) or (AutnTitleField == "") or (AutnTitleField == "No Slide Title") then
		updateField(document, "DRETITLE", DrereferenceContent, "update")
		updateField(document, "autn:title", DrereferenceContent, "update")
	end

	--The purpose of this script is to remap the IDX field pertaining to date ("CREATED") to DREDATE.
	local dateCreate = getFieldValue(document,"CREATED")
	local dateMod = getFieldValue(document,"LASTMODIFIED")
	if dateMod then
		updateField(document, "DREDATE", dateMod, "update")
	elseif dateCreate then
		updateField(document, "DREDATE", dateCreate, "update")
	end
	
	-- fix SP 
local db = getFieldValue(document,"DREDBNAME")
if db == "SP2007" then
updateField(document, "AUTONOMYMETADATA", "", "update")
updateField(document, "SECURITYTYPE", "", "update")
end


end
	
-- ======================================================
-- Auxiliary Functions
-- ======================================================

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- only single valued for now
function getFieldValue (document, fieldName)
	local field = getField(document, fieldName)
	return field and document:fieldGetValue(field) or nil
end

-- adds/updates a field in all sections of a document
function updateField (document, name, value, addOrReplace)
	if addOrReplace == "add" then
		addField(document, name, value)
	else
		-- replace adds if it does not find field; so this is default
		replaceField(document, name, value)
	end
end

-- only single valued for now
function getField(document, fieldName)
	local section = document
	local field = nil
	while section do
		field = section:findField(fieldName)
		if field then break end
		section = section:getNextSection()
	end
	return field
end

-- adds a field to all sections of a document
function addField (document, name, value)
	local section = document
	while section do
		section:addField(name, value)
		section = section:getNextSection()
	end
end

-- replaces a field in all sections of a document
function replaceField (document, name, value)
	local field = getField(document, name)
	if field then
		-- update field in all sections
		local section = document
		while section do
			section:fieldSetValue(field, value)
			section = section:getNextSection()
		end
	else
		-- field does not exist in any section; so fall back to add
		addField(document, name, value)
	end
end


--The purpose of this script is to set AUTN:TITLE to DREREFERENCE if <autn:title> No Slide Title </autn:title>.
function handler (document)

  local AutnTitleField = document:getFieldValue("autn:title") 
  local DrereferenceContent = document:getFieldValue("DREREFERENCE")
  if AutnTitleField == "No Slide Title" then
    document:setFieldValue("autn:title", DrereferenceContent)
  end

end
--The purpose of this script is to remap the IDX field pertaining to date ("CREATED") to DREDATE.
function handler (document)

  local dateCreate = document:getFieldValue("CREATED") 
  local dateMod = document:getFieldValue("LASTMODIFIED")
  if dateCreate then
    document:setFieldValue("DREDATE", dateCreate)
  elseif dateMod then
    document:setFieldValue("DREDATE", dateMod)
  end
  
end
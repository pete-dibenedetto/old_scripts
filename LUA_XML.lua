function handler(document)

       local myLongUserField = document:findField("user")

     if myLongUserField ~= nil then

		local myScreenName = myLongUserField:getAttributeValue("id")

		document:addField("GotUserStatus", "OK")


		if myScreenName ~= nil then

			log("lua.log","newName2")
			document:addField("SCREEN_NAME",newName)

		else

			log("lua.log","No Screen Name")

		end
     else
           document:addField("GotUserStatus", "ERROR")
		log("lua.log","error")
     end

return true
end

handler()

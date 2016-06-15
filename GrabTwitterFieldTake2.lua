function handler(document)

	local microMedia = "Micro Media"

	local handle = document:findField("user/\/@screen_name")
	--local crazyFieldName = "entities/user_mentions/@screen_name"

   local handle = document:findField(crazyFieldName)
       if nil ~= handle then
              document:addField("HANDLE", document:getFieldValue(crazyFieldName))
              local twitterHandle = document:getFieldValue(crazyFieldName)
       

	local twitterTweetID = document:getFieldValue("DREREFERENCE")
	
	local twitterURL = "https://twitter.com/"
	
	if twitterHandle then
	
		local twitterFullPath = twitterURL..twitterHandle.."/statuses/"..twitterTweetID


		document:addField("TWITTER_ID",twitterHandle)
		document:addField("TWEET_NUMBER",twitterTweetID)
		document:addField("TWEET_URL", twitterFullPath)
	
		document:setFieldValue("DREREFERENCE",twitterFullPath)
	end
end
	document:addField("TYPE", microMedia)
	
	
	return true
end
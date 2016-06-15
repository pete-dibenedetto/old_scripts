function handler(document)

	local microMedia = "Micro Media"

	local twitterHandle = document:getFieldValue("entities/user_mentions/@screen_name")
	local twitterTweetID = document:getFieldValue("DREREFERENCE")
	
	local twitterURL = "https://twitter.com/"

	local twitterFullPath = twitterURL..twitterHandle.."/statuses/"..twitterTweetID


	document:addField("TWITTER_ID",twitterHandle)
	document:addField("TWEET_NUMBER",twitterTweetID)
	document:addField("TWEET_URL", twitterFullPath)
	
	document:setFieldValue("DREREFERENCE",twitterFullPath)
	
	
	document:addField("TYPE", microMedia)
	
	
	return true
end
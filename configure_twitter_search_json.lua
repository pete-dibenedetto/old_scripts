-- ################ CONFIG ################

function getConfigOptions()
         return {
		SSLMethod="SSLV23",
		ConnectionLibrary="connectionTwitter.dll",
		SynchronizeKeepDatastore="FALSE",
		JsonUseXmlAttributes="FALSE"
	}
end

function getDateFormats()
	return { "YYYY-MM-DDTHH:NN:SS", "DD MMM YYYY HH:NN:SS"}
end

function postProcessDownload(url, httperr, content)
	print(httperr, url)
	if httperr ~= 200 then
		print(content)
	end
end

function urlEscape( value )
	if value == nil then
		return nil
	end
	return value:gsub("([^0-9a-zA-Z])", function (c) return string.format("%%%02X", string.byte(c)) end)
end

function getMonth(month)
        local months = { Jan="01", Feb="02", Mar="03", Apr="04", May="05", Jun="06", Jul="07", Aug="08", Sep="09", Oct="10", Nov="11", Dec="12" }
	return months[month]
end
-- ################ FEED URL ################

function getFeedUrls()

	local config = get_config()
	local section = get_param("SECTION")

	local url = "https://search.twitter.com/search.json"
	local params = {}
	
	-- See if they have a pre-set country
	country = config:getValue(section, "COUNTRY", "")

        -- Include extra entities such as mentions, media and hash tags (can't do this in atom feed)
	params["include_entities"] = "true"

	local query = config:getValue(section, "QUERY", "")
	if query ~= nil and query ~= "" then
		params["q"] = urlEscape(query)
	end

	local lang = config:getValue(section, "LANG", "en") -- ISO 639-1
	if lang ~= nil and lang ~= "" then
		params["lang"] = lang
	end

	local type = config:getValue(section, "TYPE", "")
	if type ~= nil and type ~= "" then
		type = type:lower()
		if type == "mixed" or type == "recent" or type == "popular" then
			params["result_type"] = type
		else
			error("TYPE must be mixed(default)|recent|popular")
		end
	end

	local latitude = tonumber(config:getValue(section, "LATITUDE", ""))
	local longitude = tonumber(config:getValue(section, "LONGITUDE", ""))
	local distancewithunit = config:getValue(section, "DISTANCE", "")
	local distancestr,unit = distancewithunit:match("^(.-)([mk]?[im]?)$")
	local distance = tonumber(distancestr)
	if latitude ~= nil and longitude ~= nil and distance ~= nil then
		if unit ~= "mi" and unit ~= "km" then
			unit = "km"
		end
		params["geocode"] = tostring(latitude)..","..tostring(longitude)..","..tostring(distance)..unit
	end

	local pagesize = config:getValue(section, "PAGESIZE", 100)
	params["rpp"] = pagesize

	local maxresults = config:getValue(section, "MAXRESULTS", 1500)
	set_param("MAXRESULTS", maxresults)

	local sep = "?"
	for k,v in pairs(params) do
		url = url..sep..k.."="..v
		sep = "&"
	end
	return { url }

end

-- ################ FEED ################

function getEntryXPaths()
	cache_result()
	return { "/json/results" }
end

function getNextUrlParameters(xml)
	local entryCount = tonumber(xml:XPathValue("count(/json/results)"))
	local results = get_param("RESULTS", 0) + entryCount
	set_param("RESULTS", results)
	if results < tonumber(get_param("MAXRESULTS")) and entryCount > 0 then
		local nexturl = xml:XPathValue("/json/next_page")
		local maxid = xml:XPathValue("/json/max_id_str")
		set_param("PAGE", tonumber(xml:XPathValue("/json/page")) + 1)
		return { page=get_param("PAGE"), max_id=maxid }
	end
	return {}
end

-- ################ ENTRY ################

function getEntryIdXPath()
	cache_result()
	return "~/id"
end

function getEntryMetadataXPaths()
	cache_result()
	return {
		ID="~/id",
		AUTHOR_NAME="~/from_user",
		AUTHOR_ID="~/from_user_id",
		AUTHOR_REALNAME="~/from_user_name",
		LOCATION="~/location",
		RESULT_TYPE="~/metadata/result_type",
		LANG="~/iso_language_code",
		DRETITLE="~/text",
		DRECONTENT="~/text",
		PROFILE_IMG="~/profile_image_url"
        }
end

function getEntryMetadata(xml, doc)
    -- The dates come in JSON format (25 Jun 2012 20:12:00 +0000)
    -- so convert them to IDOL format
    p="%a+, (%d+) (%a+) (%d+) (%d+):(%d+):(%d+) %+(%d+)"
    day,month,year,hour,min,sec,tz= xml:XPathValue("~/created_at"):match(p)
    fixedDate = year.."-"..getMonth(month).."-"..day.." "..hour..":"..min..":"..sec.." GMT"

    local returnObj =  {
        DREDATE=fixedDate,
        PUBLISHED_DATE=fixedDate,
        UPDATED_DATE=fixedDate,
        TYPE="Micro Media",
        SOURCEURL="http://twitter.com/"..xml:XPathValue("~/from_user").."/statuses/"..xml:XPathValue("~/id")
    }
    if xml:XPathValue("~/to_user") ~= "null" then
       returnObj.REPLYTO_USER = xml:XPathValue("~/to_user")
       returnObj.REPLYTO_USER_ID = xml:XPathValue("~/to_user_id")
       returnObj.REPLYTO_USER_REALNAME = xml:XPathValue("~/to_user_name")
    end

    -- entity handling
    -- We add these into the Document rather than in the returnObj as we could end up
    -- with multiple of the same name and you can't have same name keys in a lua table
    local url_count = tonumber(xml:XPathValue("count(~/entities/urls)"))
    for ii = 1, url_count do
        doc:addField('URLS', xml:XPathValue("~/entities/urls["..ii.."]/expanded_url"))
    end

    local hash_count = tonumber(xml:XPathValue("count(~/entities/hashtags)"))
    for ii = 1, hash_count do
        doc:addField('HASH', xml:XPathValue("~/entities/hashtags["..ii.."]/text"))
    end

    local media_count = tonumber(xml:XPathValue("count(~/entities/media)"))
    for ii = 1, media_count do
        doc:addField('MEDIA', xml:XPathValue("~/entities/media["..ii.."]/media_url"))
    end

    local mentions_count = tonumber(xml:XPathValue("count(~/entities/user_mentions)"))
    for ii = 1, mentions_count do
        doc:addField('MENTIONS_NAME', xml:XPathValue("~/entities/user_mentions["..ii.."]/screen_name"))
    end

    -- Check if it's a retweet
    local content = xml:XPathValue("~/text")
    if string.find(content, "RT @") or string.find(content, "RT@") then
        returnObj.RETWEET = "true"
    else
        returnObj.RETWEET = "false"
    end
    
    -- Add the predefined country in (if set)
    if country ~= "" then
        returnObj.COUNTRY = country
    end

    return returnObj
end
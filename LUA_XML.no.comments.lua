function handler(document)

                local mydocfields = {document:getFields("MYDOC")}
                for k, v in pairs(mydocfields) do
                                local mydocnames = { v:getFieldValues("NAME") }
                                for k1, v1 in pairs(mydocnames) do
                                                log(v1)
                                end
                end

                return true
end

function log(content)
                if((disableLog == nil) or (disableLog == false)) then
                                local f = io.open('logs\\lua.log', 'a')
                                f:write(os.date() .. ' ' .. content .. '\n')
                                f:close()
                end
end

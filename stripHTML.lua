function convertEntities(str)

       str = string.gsub(str, "&#(%d+);",

              function(c)

                     return string.format("%c", c)

              end)

       return str

end

function stripHTML(document,fieldname)

       fldptr = document:findField(fieldname)

       str = document:fieldGetValue(fldptr)
       
       str = string.gsub(str,"<.->","")

       str = convertEntities(str)
       
       document:fieldSetValue(fldptr, str)

end

 

function handler(document)

	stripHTML(document,"HTML1")
	
	stripHTML(document,"HTML2")

       return true

end

 

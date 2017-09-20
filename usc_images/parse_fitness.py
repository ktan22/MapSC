import re


final_string = "static let usc_libraries = [\n"
for line in open("libraries",'r'):
	mo = re.search("(.*) \((.*)\) (.*)\$(.*),(.*)",line)
	if mo is not None:
		fields = mo.groups()
		name = fields[0]
		abbrev = fields[1]
		description = fields[2]
		lat = fields[3]
		lon = fields[4]
		final_string += "\t[\"name\": \""+name+"\", \"image\": \"" + abbrev +".jpg\", \"code\": \"" + abbrev + "\", \"lat\": \"" +lat+"\", \"lng\": \"" + lon + "\", \"content\": \""+description+"\"],\n"

final_string += "]\n"
print final_string
import re
outfile = open("usc_locations.swift", 'w')

outfile.write("import Foundation\n\n\n")
outfile.write("struct ConstantMap{\n")
outfile.write("\tstatic let usc_map = [\n")

for line in open("usc_locations",'r'):
	mo = re.search("^([0-9.]*.[0-9]*)\t([A-Z]*)\s*(.*)\t(.*)",line)
	array = mo.groups()
	ID= array[0]
	key = array[1]
	name = array[2]
	address = array[3]
	
	toWrite = "\t\t"
	toWrite += "\""+key+"\":\n"
	toWrite += "\t\t\t[\"id\": \""+ID+"\", \"name\": \""+name+"\", \"address\": \""+address+"\"],\n"

	outfile.write(toWrite)

outfile.write("\n};\n")


outfile.close()
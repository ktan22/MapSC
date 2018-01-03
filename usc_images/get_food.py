import urllib2
import re
import image_scraper

final_string = "static let usc_dining = [\n"
field = {}
count = 0
outfile = open("temp_location_map",'w')
titles = []

for line in open("dining_location_map",'r'):

	if count == 6:
		final_string += "\t[\"name\": \"" + field["name"] + "\", \"image\": \"" + field["image"] + "\", \"code\": \"" + field["code"] + "\", \"lat\": \"" + field["lat"] + "\", \"lng\": \""+ field["lng"] + "\", \"content\": \"" + field["content"] + "\"],\n" 
		count = 0

	mo_name = re.search(".*\"title\":.*\"(.*)\",",line)
	if mo_name is not None:
		get = mo_name.groups()
		name = get[0]
		field["name"] = name
		count += 1
		continue

	mo_content = re.search(".*\"content\":.*\"(.*)\",",line)
	if mo_content is not None:
		get = mo_content.groups()
		content = get[0]
		field["content"] = content
		count += 1
		continue

	mo_code = re.search(".*\"code\":.*\"(.*)\",",line)
	if mo_code is not None:
		get = mo_code.groups()
		code = get[0]
		field["code"] = code
		count += 1
		continue

	mo_lat = re.search(".*\"lat\":.*\"(.*)\",",line)
	if mo_lat is not None:
		get = mo_lat.groups()
		lat = get[0]
		field["lat"] = lat
		count += 1
		continue

	mo_lon = re.search(".*\"lng\":.*\"(.*)\"",line)
	if mo_lon is not None:
		get = mo_lon.groups()
		lon = get[0]
		field["lng"] = lon
		count += 1
		continue

	mo_image = re.search(".*\"image\":(.*\\\/)(.*)(\\\\\"\s*class.*),",line)
	if mo_image is not None:
		get = mo_image.groups()
		image = get[1]
		#print image
		field["image"] = image
		count += 1
		continue

	moo = re.search(".*\"(.*)\":.*{",line)
	if moo is not None:
		get = moo.groups()
		title = get[0]
		if title == "center":
			continue
		titles.append(title)



final_string += "]\n"
print titles



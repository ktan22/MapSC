import urllib2
import re
import image_scraper

website = urllib2.urlopen("http://fmsmaps4.usc.edu/usc/php/bl_list_no.php")
html  = website.read()
html_array = html.split('\n')

link_string = "http://fmsmaps4.usc.edu/usc/php/facilities.php?OBJ_KEYS="

num_set = set()
for line in html_array:
	nums = re.search("^.*OBJ_KEYS=(.*)\" .*",line)
	if nums is not None:
		mo = nums.groups()
		float_ver = float(mo[0])
		str_ver = str(float_ver)
		if(str_ver[len(str_ver) - 1] == '0'):
			float_ver = int(mo[0])
		
		num_set.add(float_ver)

for num in num_set:
	full_url = link_string + str(num)
	#image_scraper.scrape_images(full_url)
	print(full_url)



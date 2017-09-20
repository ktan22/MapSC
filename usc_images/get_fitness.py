import urllib2
import re
import image_scraper

website = urllib2.urlopen("https://web-app.usc.edu/mobile/maps/#athletic")
html  = website.read()

print html
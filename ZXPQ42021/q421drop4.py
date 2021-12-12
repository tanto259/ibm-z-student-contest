import sys
import csv
import re
import requests
from requests.sessions import extract_cookies_to_jar

# Obtain data set from command line argument
url = sys.argv[1]

# Obtain HTML of the contact-sheet page
contactSheet = requests.get(url).text

# Get mapper URL
mapper = sorted(re.findall(r"data-z\[(.*)'", contactSheet))
mapper = [l[4:] for l in mapper]
mapper[1] = ":" + mapper[1]
mapper = ''.join(mapper)

# Obtain mapper JSON
mapperJson = requests.get(mapper).json()

# Loop through JSON
for i in mapperJson:
    if i['type'] == 'locator converter':
        locator = str(i['url']['protocol']) + "://" + str(i['url']['host']) + \
                  ":" + str(i['url']['port']) + str(i['url']['path'])
        continue
    if i['type'] == 'address converter':
        address = str(i['url']['protocol']) + "://" + str(i['url']['host']) + \
                  ":" + str(i['url']['port']) + str(i['url']['path'])
        continue
    if i['type'] == 'service details':
        service = str(i['url']['protocol']) + "://" + str(i['url']['host']) + \
                  ":" + str(i['url']['port']) + str(i['url']['path'])
        continue

# Obtain HTML of the service details
serviceDetails = requests.get(service).text

# Open output file
output = open('q421drop4-output.txt', 'a')
locationOutput = open('q421drop4-location.txt', 'a')

# Get first record
host = re.findall(r"<dt>Host<\/dt>\n[ \t]*<dd>(.*)<\/dd>", serviceDetails)[0]
platform = re.findall(r"<dt>Platform<\/dt>\n[ \t]*<dd>(.*)<\/dd>", serviceDetails)[0]
os = re.findall(r"<dt>OS<\/dt>\n[ \t]*<dd>(.*)<\/dd>", serviceDetails)[0]
firstRec = "host:" + str(host) + " platform:" + str(platform) + " os:" + str(os) + '\n'

# Write first record
output.write(firstRec)

# Set list and variables
north = None
south = None
east = None
west = None
location_list = []
validNameList = []

# Read output from Drop3 and sort them in ascending based on name
with open('q421drop3-output.txt') as csvfile:
    csvReader = csv.reader(csvfile, delimiter=',')
    sortedReader = sorted(list(csvReader), key=lambda row: row[3])

    for field in sortedReader:
        id, name, location = field[2:]
        
        # Get address
        addrCode = requests.get(locator.replace("{locator}", location)).json()["ADDRESS"]
        latLong = requests.get(address.replace("{address}", addrCode)).json()
        latitude = latLong["LAT"]
        longitude = latLong["LNG"]

        # Set bounding box
        if north:
            if latitude > north:
                north = latitude
        else:
            north = latitude

        if south:
            if latitude < south:
                south = latitude
        else:
            south = latitude

        if west:
            if longitude < west:
                west = longitude
        else:
            west = longitude

        if east:
            if longitude > east:
                east = longitude
        else:
            east = longitude  
        
        # Final record
        finRec = str(id) + ',"' + str(name) + '","' + str(location) + '",' + str(latitude) + ',' + str(longitude) + '\n'
        location_list.append(finRec)

# Write bounding box
output.write(str(north) + "," + str(west) + " " + str(south) + "," + str(east) + '\n') 

# Write final records
output.write(''.join(location_list))
locationOutput.write(''.join(location_list))

# Close output
output.close()
locationOutput.close()
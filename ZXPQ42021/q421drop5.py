import csv
from datetime import datetime

# Set up initial HTML template
initial = """<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">

    <!-- Mapbox API -->
    <link href="https://api.mapbox.com/mapbox-gl-js/v2.5.1/mapbox-gl.css" rel="stylesheet">
    <script src="https://api.mapbox.com/mapbox-gl-js/v2.5.1/mapbox-gl.js"></script>
    <style>
        .mapbox { height: 350px; }
    </style>

    <title>IBM Z Student Contest October 2021</title>
  </head>
  <body>
    <div class="col-lg-8 mx-auto p-3 py-md-5">
        <div class="container">
            <h1>IBM Z Student Contest</h1>
            <h2>Vehicle Requirement Report</h2>
            <h4>By Hartanto Ario Widjaya</h4>
            <hr class="my-4">
            <h3 class="my-4">?VEHICLE?</h3>
            <div class="list-group">
                <li class="list-group-item list-group-item-primary">Required Assemblies</li>
                ?ASSEMBLIES?
            </div>
            <hr class="my-4">
            ?LISTING? 
            <hr class="my-4">
            <div class="footer-copyright text-center">
                Generated on ?DATE?
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.6.0.slim.min.js" integrity="sha256-u7e5khyithlIdTpu22PHhENmPcRdFiHRjhAuHcs05RI=" crossorigin="anonymous"></script>

    <script>
        mapboxgl.accessToken = 'MAPBOX-ACCESS-TOKEN';
        ?MAPBOX?
    </script>

    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>

  </body>
</html>"""

# Get vehicle name
for line in open('q421drop1-output.txt'):
    initial = initial.replace("?VEHICLE?", line[0:4])

# Set up list
assemblyList = []
guidList = []
vendorList = []
vendorNameDict = {}
engineerVendorId = []
engineerIdList = []
engineerNameList = []
engineerLocator = []
engineerLatitude = []
engineerLongitude = []
validNameList = []

# Get bounding box
with open('q421drop4-output.txt') as fp:
    for i, line in enumerate(fp):
        if i == 1:
            box = line.split()
        elif i > 1:
            break

northwest = box[0].split(",")
southeast = box[1].split(",")

midpointLat = (float(northwest[0]) + float(southeast[0])) / 2
midpointLng = (float(northwest[1]) + float(southeast[1])) / 2

# Open the assembly,guid,vendor list
with open('q421drop5-valid-vendors.txt') as csvfile:
    csvReader = csv.reader(csvfile, delimiter=',')
    for asm, guid, vendor in csvReader:
        assemblyList.append(asm)
        guidList.append(guid)
        vendorList.append(vendor)

# Open valid engineers
with open('q421drop2-output.txt') as fp:
    for line in fp:
        validNameList.append(line[0:8])

# Open valid location
with open('q421drop5-location-list.txt') as csvfile:
    csvReader = csv.reader(csvfile, delimiter=',')
    for vendor, vendorName, engineerId, engineerName, engineerLoc, engineerLat, engineerLng in csvReader:
        # We assume that the Db2 schema contain only matching engineers
        # https://ibmzxplore.influitive.com/forum/t/drop-1-to-drop-2-inconsistent-vendor-numbers/331/11
        #if engineerName in validNameList:
            vendorNameDict[vendor.zfill(6)] = vendorName
            engineerVendorId.append(vendor.zfill(6))
            engineerIdList.append(engineerId)
            engineerNameList.append(engineerName)
            engineerLocator.append(engineerLoc)
            engineerLatitude.append(engineerLat)
            engineerLongitude.append(engineerLng)

# Form required assembly HTML
requiredAssembly = ""
uniqueAssembly = set(assemblyList)
for asm in uniqueAssembly:
    requiredAssembly += '<label class="list-group-item">'
    requiredAssembly += '<input class="form-check-input me-1" type="checkbox" value="">'
    requiredAssembly += 'Assembly ' + asm
    requiredAssembly += '</label>'
initial = initial.replace("?ASSEMBLIES?", requiredAssembly)

# Final list of valid engineers
requiredEngineers = []

# Form listing of parts
listingPart = ""
mapBox = ""
for asm in uniqueAssembly:
    indices = [i for i, x in enumerate(assemblyList) if x == asm]
    listingPart += '<h4 class="my-4">Assembly ' + asm + '</h3>'
    listingPart += '<div class="accordion">'
    for index in indices:
        guid = guidList[index]
        vendorId = vendorList[index]
        listingPart += '<div class="accordion-item">'
        listingPart += '<h2 class="accordion-header" id="heading-' + guid + '">'
        listingPart += '<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapse-' + guid + '" aria-expanded="false" aria-controls="collapse-' + guid + '">'
        listingPart += 'Part ' + guid                    
        listingPart += '</button>'
        listingPart += '</h2>'
        listingPart += '<div id="collapse-' + guid + '" class="accordion-collapse collapse" aria-labelledby="heading-' + guid + '" data-bs-parent="#accordionExample">'
        listingPart += '<div class="accordion-body">'
        listingPart += '<p class="lead">Vendor ' + vendorId + ' - ' + vendorNameDict.get(vendorId) + '</p>'
        listingPart += '<div class="table-responsive">'
        listingPart += '<table class="table">'
        listingPart += '<thead>'
        listingPart += '<tr>'
        listingPart += '<th scope="col">ID</th>'
        listingPart += '<th scope="col">Name</th>'
        listingPart += '<th scope="col">Location</th>'
        listingPart += '</tr>'
        listingPart += '</thead>'
        listingPart += '<tbody>'
        mapBox += "const map_" + guid.replace("-", "_") + " = new mapboxgl.Map({"
        mapBox += "container: 'map-" + guid + "',"
        mapBox += "style: 'mapbox://styles/mapbox/streets-v11',"
        mapBox += "center: [" + str(midpointLng) + ", " + str(midpointLat) + "],"
        mapBox += "zoom: 8"
        mapBox += "});"
        mapBox += "$('#collapse-" + guid + "').on('shown.bs.collapse', function () {"
        mapBox += "map_" + guid.replace("-", "_") + ".resize();"
        mapBox += "});"
        engIndices = [i for i, y in enumerate(engineerVendorId) if y == vendorId]
        for engIndex in engIndices:
            requiredEngineers.append(engineerIdList[engIndex])
            listingPart += '<tr>'
            listingPart += '<th scope="row">' + engineerIdList[engIndex] + '</th>'
            listingPart += '<td>' + engineerNameList[engIndex] + '</td>'
            listingPart += '<td>' + engineerLatitude[engIndex] + ', ' + engineerLongitude[engIndex] + '</td>'
            listingPart += '</tr>'
            mapBox += "const marker_" + engineerIdList[engIndex] + " = new mapboxgl.Marker()"
            mapBox += ".setLngLat([" + engineerLongitude[engIndex] + ', ' + engineerLatitude[engIndex] + "])"
            mapBox += ".setPopup(new mapboxgl.Popup().setHTML('<p>#" + engineerIdList[engIndex] + " - " + engineerNameList[engIndex] + "</p>'))"
            mapBox += ".addTo(map_" + guid.replace("-", "_") + ");"
        listingPart += '</tbody>'
        listingPart += '</table>'
        listingPart += '</div>'
        listingPart += '<div class="mapbox" id="map-' + guid + '"></div>'
        listingPart += '</div>'
        listingPart += '</div>'
        listingPart += '</div>' 
    listingPart += '</div>'
initial = initial.replace("?LISTING?", listingPart)
initial = initial.replace("?MAPBOX?", mapBox)

# Get date and time
now = datetime.now()
initial = initial.replace("?DATE?", now.strftime("%A, %d %B %Y %H:%M:%S %Z"))

# Write to report file
reportFile = open('q421-report.html', 'a')
reportFile.write(initial)
reportFile.close()

# Open output file
finalList = []
output = open('q421drop5-output.txt', 'a')

# Filter through valid engineers
for id in engineerIdList:
    index = engineerIdList.index(id)
    tempList = [id, '"' + engineerNameList[index] + '"', '"' +engineerLocator[index] + '"', engineerLatitude[index], engineerLongitude[index]]
    finalList.append(tempList)
finalList = sorted(finalList, key=lambda l:l[1])

# Print headers
with open('q421drop4-output.txt') as fp:
    for i, line in enumerate(fp):
        if i <= 1:
            output.write(line)
        elif i > 1:
            break

# Print engineers
for line in finalList:
    output.write(",".join(line) + '\n')

# Print file name and close file
output.write("q421-report.html" + '\n')
output.close()

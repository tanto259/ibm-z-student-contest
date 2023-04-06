import sys
import base64
import csv
from zoautil_py import datasets

dataPrefix = sys.argv[1]
search = sys.argv[2]

searchData = base64.b64decode(datasets.read(search)).decode('ascii')

validMembers = []

with open('/z/ZUSER/Q4Y22/drop1-valid-members.txt') as fp:
    for line in fp:
        validMembers.append(line.strip())

validData = []

for mem in validMembers:
    result = datasets.read(str(dataPrefix) + "(" + mem + ")").splitlines()
    reader = csv.reader(result, delimiter='$')
    headers = next(reader)
    data = [{h:x for (h,x) in zip(headers,row)} for row in reader]
    for d in data:
        d.update((h, base64.b64decode(x).decode('ascii')) for h, x in d.items() if h == "desc")
        d['member'] = mem
    validData += [d for d in data if searchData.lower() in d['desc'].lower()]
    
sortedData = sorted(validData, key=lambda d: d['mea'])

output = open('/z/ZUSER/Q4Y22/drop1-output.txt', 'a')
rawOutput = open('/z/ZUSER/Q4Y22/drop1-raw-output.txt', 'a')

for sort in sortedData:
    output.write(sort['member'] + ',' + sort['mea'] + ',' + sort['man'] + '\n')
    rawOutput.write(sort['member'] + ',' + sort['id'] + ',' + sort['man'] + ',' + sort['mea'] + ',' + sort['shade'] + ',' + sort['desc'] + '\n')

output.close()
rawOutput.close()

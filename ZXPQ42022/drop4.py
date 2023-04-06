import csv
import base64

procRankList = {}

with open('/z/ZUSER/Q4Y22/drop4-proc.txt') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    headers = next(reader)
    procRankList = {row[0]:row[1] for row in reader}

with open('/z/ZUSER/Q4Y22/drop4-combined.txt') as csvfile:
    reader = csv.reader(csvfile, delimiter='|')
    headers = ['productCode', 'latitude', 'longitude', 'procCode', 'procClass', 'vendorCode', 'vendorName', 'vendorRank']
    data = [{h:x for (h,x) in zip(headers,row)} for row in reader]
    for d in data:
        d.update((h, base64.b64decode(x).decode('ascii')) for h, x in d.items() if h == "procClass")
        d.update((h, int(x)) for h, x in d.items() if h == "vendorRank")
        d['procColor'] = d['procClass'].split("--")[0]
        d.update(("procRank", int(x)) for h, x in procRankList.items() if h == d['procColor'])
    data = sorted(data, key=lambda d: (-d['vendorRank'], d['procRank'], d['productCode']))
    
    output = open('/z/ZUSER/Q4Y22/drop4-output.txt', 'a')

    for d in data[:3]:
        output.write(str(d['procRank']) + ',' + d['productCode'] + ',' + d['vendorCode'] + '\n@' + d['procColor'] + '@' + str(d['vendorRank']) + '@' + d['vendorName'] + '\n')

    output.close()
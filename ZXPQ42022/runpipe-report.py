import os
import sys
import csv
import json

# Obtain URL
reportLoc = sys.argv[1]
reportLoc = reportLoc.replace("~", "/z/ZUSER")

# Get additional MEA details
drop1 = open('/z/ZUSER/Q4Y22/drop1-raw-output.txt')
reader = csv.reader(drop1, delimiter=',')
headers = ['memberName', 'meaId', 'manCode', 'meaCode', 'meaShade', 'meaDesc']
meaData = [{h:x for (h,x) in zip(headers,row)} for row in reader]
drop1.close()

# Get additional STK details
drop2 = open('/z/ZUSER/Q4Y22/drop2-raw-output.txt')
reader = csv.reader(drop2, delimiter=',')
headers = ['stkCode', 'manCode', 'stkQuantity', 'manName', 'manValid', 'stkName']
stkData = [{h:x for (h,x) in zip(headers,row)} for row in reader]
drop2.close()

# Get additional GAS details
drop4 = open('/z/ZUSER/Q4Y22/drop4-combined.txt')
reader = csv.reader(drop4, delimiter='|')
headers = ['gasCode', 'gasLat', 'gasLong', 'processCode', 'processClass', 'venCode', 'venName', 'venRank']
gasData = [{h:x for (h,x) in zip(headers,row)} for row in reader]
drop4.close()

# Get Drop 5 JSON
drop5 = open('/z/ZUSER/Q4Y22/drop5-raw-output.txt')
validList = json.load(drop5)
drop5.close()

# Print markdown
os.makedirs(os.path.dirname(reportLoc), exist_ok=True)
report = open(reportLoc, 'w')

report.write("# Fuel Cell Parts Report\n")
report.write('\n')
report.write("**Set Identification**: " + validList[0]['set'] + '\n')
report.write('\n')
report.write("## Summary\n")
report.write('\n')
report.write("| Type | Parts Code | Manufacturer or Vendor Name | Quantity |\n")
report.write("| ---- | ---------- | --------------------------- | -------- |\n")

for item in validList:
    report.write("|" + item['type'] + "|" + item['code'] + "|" + item['name'] + "|" + str(item['quantity']) + "|\n")

report.write('\n')
report.write("## Details\n")
report.write('\n')
report.write("### Membrane Electrode Assembly")
report.write('\n')

validMea = [d['code'] for d in validList if d['type'] == "MEA"][0]
meaShade = [d['meaShade'] for d in meaData if d['meaCode'] == validMea][0]

report.write("- **Parts Code**: " + validMea + '\n')
report.write("- **Parts Description**: " + [d['meaDesc'] for d in meaData if d['meaCode'] == validMea][0] + '\n')
report.write("- **Parts Color Shade**: [" + meaShade + "](https://www.color-hex.com/color/" + meaShade[1:] + ")" + '\n')
report.write("- **Manufacturer Name**: " + [d['name'] for d in validList if d['type'] == "MEA"][0] + '\n')
report.write("- **Manufacturer Code**: " + [d['manufacturer'] for d in validList if d['type'] == "MEA"][0] + '\n')
report.write("- **Quantity**: " + str([d['quantity'] for d in validList if d['type'] == "MEA"][0]) + '\n')
report.write("- **Member Name**: " + [d['memberName'] for d in meaData if d['meaCode'] == validMea][0] + '\n')

report.write('\n')
report.write("### Stack Plates")
report.write('\n')

validStk = [d['code'] for d in validList if d['type'] == "STK"][0]

report.write("- **Parts Code**: " + validStk + '\n')
report.write("- **Parts Name**: " + [d['stkName'] for d in stkData if d['stkCode'] == validStk][0] + '\n')
report.write("- **Manufacturer Name**: " + [d['name'] for d in validList if d['type'] == "STK"][0] + '\n')
report.write("- **Manufacturer Code**: " + [d['manufacturer'] for d in validList if d['type'] == "STK"][0] + '\n')
report.write("- **Quantity**: " + str([d['quantity'] for d in validList if d['type'] == "STK"][0]) + '\n')

report.write('\n')
report.write("### Gaskets")
report.write('\n')

report.write("- **Parts Code**: " + [d['code'] for d in validList if d['type'] == "GSK"][0] + '\n')
report.write("- **Vendor Name**: " + [d['name'] for d in validList if d['type'] == "GSK"][0] + '\n')
report.write("- **Quantity**: " + str([d['quantity'] for d in validList if d['type'] == "GSK"][0]) + '\n')

report.write('\n')
report.write("### Gas")
report.write('\n')

validGas = [d['code'] for d in validList if d['type'] == "GAS"][0]
gasLat = [d['gasLat'] for d in gasData if d['gasCode'] == validGas][0]
gasLong = [d['gasLong'] for d in gasData if d['gasCode'] == validGas][0]

report.write("- **Parts Code**: " + validGas + '\n')
report.write("- **Vendor Name**: " + [d['name'] for d in validList if d['type'] == "GAS"][0] + '\n')
report.write("- **Vendor Code**: " + [d['manufacturer'] for d in validList if d['type'] == "GAS"][0] + '\n')
report.write("- **Vendor Location**: [" + gasLat + ", " + gasLong + "](https://earth.google.com/web/search/" + gasLat + "," + gasLong + "/)" + '\n')
report.write("- **Quantity**: " + str([d['quantity'] for d in validList if d['type'] == "GAS"][0]) + '\n')

report.write('\n')
report.close()
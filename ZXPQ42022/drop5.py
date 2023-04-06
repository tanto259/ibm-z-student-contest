import re
import sys
import csv
import json
import base64
import requests

# Obtain URL
url = sys.argv[1]

# Get valid MEA
drop1 = open('/z/ZUSER/Q4Y22/drop1-output.txt')
reader = csv.reader(drop1, delimiter=',')
headers = ['memberName', 'meaCode', 'manCode']
meaData = [{h:x for (h,x) in zip(headers,row)} for row in reader]
meaCodeList = [d['meaCode'] for d in meaData]
drop1.close()

# Get valid STK
drop2 = open('/z/ZUSER/Q4Y22/drop2-output.txt')
reader = csv.reader(drop2, delimiter=',')
headers = ['stkCode', 'manCode', 'stkQuantity', 'manName']
stkData = [{h:x for (h,x) in zip(headers,row)} for row in reader]
stkCodeList = [d['stkCode'] for d in stkData]
drop2.close()

# Get valid GSK
drop3 = open('/z/ZUSER/Q4Y22/drop3-vendors.txt')
reader = csv.reader(drop3, delimiter=":")
headers = ['gskCode', 'venName']
gskData = [{h:x for (h,x) in zip(headers,row)} for row in reader]
gskCodeList = [d['gskCode'] for d in gskData]
drop3.close()

# Get valid GAS
drop4 = open('/z/ZUSER/Q4Y22/drop4-combined.txt')
reader = csv.reader(drop4, delimiter='|')
headers = ['gasCode', 'gasLat', 'gasLong', 'processCode', 'processClass', 'venCode', 'venName', 'venRank']
gasData = [{h:x for (h,x) in zip(headers,row)} for row in reader]
gasCodeList = [d['gasCode'] for d in gasData]
drop4.close()

# Loop through list of MEA
for mea in meaCodeList:
    # Get set ID
    result = requests.get(url + mea)
    jsonMea = result.json()

    setId = jsonMea['set']
    
    # Get valid STK from set ID
    stkResult = requests.get(url + "STK/" + setId)
    jsonStk = stkResult.json()

    validStkCode = jsonStk['code']
    validStkQty = jsonStk['quantity']

    # Continue through loop if no valid STK
    if validStkCode not in stkCodeList:
        continue

    # Get valid GSK from set ID
    gskResult = requests.get(url + "GSK/" + setId)
    jsonGsk = gskResult.json()

    validGskCode = jsonGsk['code']
    validGskQty = jsonGsk['quantity']

    # Continue through loop if no valid GSK
    if validGskCode not in gskCodeList:
        continue

    # Get valid GAS from set ID
    gasResult = requests.get(url + "GAS/" + setId)
    jsonGas = gasResult.json()

    validGasCode = jsonGas['code']
    validGasQty = jsonGas['quantity']

    # Continue through loop if no valid GAS
    if validGasCode not in gasCodeList:
        continue

    # Get the rest of the required values
    validStkManCode = [d['manCode'] for d in stkData if d['stkCode'] == validStkCode][0]
    validStkManName = base64.b64decode([d['manName'] for d in stkData if d['stkCode'] == validStkCode][0]).decode('ascii')

    validGskVenName = [d['venName'] for d in gskData if d['gskCode'] == validGskCode][0]

    validGasVenCode = [d['venCode'] for d in gasData if d['gasCode'] == validGasCode][0]
    validGasVenName = [d['venName'] for d in gasData if d['gasCode'] == validGasCode][0]

    # Rebuild each of the required JSON
    validMea = {}
    validMea['type'] = "MEA"
    validMea['name'] = jsonMea['name']
    validMea['manufacturer'] = jsonMea['manufacturer']
    validMea['code'] = jsonMea['code']
    validMea['quantity'] = jsonMea['quantity']
    validMea['set'] = setId

    validStk = {}
    validStk['type'] = "STK"
    validStk['name'] = validStkManName
    validStk['manufacturer'] = validStkManCode
    validStk['code'] = validStkCode
    validStk['quantity'] = validStkQty
    validStk['set'] = setId

    validGsk = {}
    validGsk['type'] = "GSK"
    validGsk['name'] = validGskVenName
    validGsk['manufacturer'] = ""
    validGsk['code'] = validGskCode
    validGsk['quantity'] = validGskQty
    validGsk['set'] = setId

    validGas = {}
    validGas['type'] = "GAS"
    validGas['name'] = validGasVenName
    validGas['manufacturer'] = validGasVenCode
    validGas['code'] = validGasCode
    validGas['quantity'] = validGasQty
    validGas['set'] = setId

    # Form the output array
    output = []
    output.append(validMea)
    output.append(validStk)
    output.append(validGsk)
    output.append(validGas)

    # Print to output
    outputFile = open('/z/ZUSER/Q4Y22/drop5-output.txt', 'w')
    outputFile.write(re.sub(r'"(.*?)"(?=:)', r'\1', json.dumps(output, indent=1)))
    outputFile.close()

    rawOutput = open('/z/ZUSER/Q4Y22/drop5-raw-output.txt', 'w')
    rawOutput.write(json.dumps(output))
    rawOutput.close()

    break
    
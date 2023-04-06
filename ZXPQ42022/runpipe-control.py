import re
from zoautil_py import datasets

control = {}

with open('/z/ZUSER/Q4Y22/runpipe-control.txt') as file:
    for line in file:
        (h, x) = line.split("=")
        control[h] = x

output = open('/z/ZUSER/Q4Y22/runpipe-setup.txt', 'w')

output.write("export MEADATA=" + '"' + control['PREFIX'].rstrip() + "." + re.search('\(([^)]+)', control['MEADATA']).group(1) + '"' + '\n')
output.write("export MEASEARCH=" + '"' + control['PREFIX'].rstrip() + ".MEA" + '"' + '\n')
output.write("export MEAMEMBER=" + '"' + re.search('\(([^)]+)', control['MEARESULTS']).group(1) + '"' + '\n')

output.write("export STKSCHEMA=" + '"' + re.search('\(([^)]+)', control['STKDATA']).group(1).split(".")[0] + '"' + '\n')
output.write("export STKSEARCH=" + '"' + control['PREFIX'].rstrip() + ".STK" + '"' + '\n')
output.write("export STKMEMBER=" + '"' + re.search('\(([^)]+)', control['STKRESULTS']).group(1) + '"' + '\n')

zfsResult = re.search('\(([^)]+)', control['GSKDATA']).group(1)
if not zfsResult.endswith("/"):
    zfsResult += "/"

output.write("export GSKZFS=" + '"' + zfsResult + '"' + '\n')
output.write("export GSKSEARCH=" + '"' + control['PREFIX'].rstrip() + ".GSK" + '"' + '\n')
output.write("export GSKMEMBER=" + '"' + re.search('\(([^)]+)', control['GSKRESULTS']).group(1) + '"' + '\n')

output.write("export GASSEARCH=" + '"' + control['PREFIX'].rstrip() + ".GAS" + '"' + '\n')
output.write("export GASMEMBER=" + '"' + re.search('\(([^)]+)', control['GASRESULTS']).group(1) + '"' + '\n')

output.write("export ASMURL=" + '"' + re.search('\(([^)]+)', control['ASMDATA']).group(1).split("<")[0] + '"' + '\n')
output.write("export ASMMEMBER=" + '"' + re.search('\(([^)]+)', control['ASMRESULTS']).group(1) + '"' + '\n')

output.write("export REPORT=" + '"' + re.search('\(([^)]+)', control['REPORT']).group(1) + '"' + '\n')

outputDataset = re.search('\(([^)]+)', control['RESULTS']).group(1).split("(")
outputDatasetName = "ZUSER." + outputDataset[0]
outputDatasetParameter = outputDataset[1].split(",")

if not datasets.exists(outputDatasetName):
    datasets.create(outputDatasetName, type="PDSE", data_class_name=outputDatasetParameter[0], record_format=outputDatasetParameter[1], record_length=outputDatasetParameter[2])

output.write("export RESULT=" + '"' + outputDatasetName + '"' + '\n')

output.close()
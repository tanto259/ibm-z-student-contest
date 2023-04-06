import shlex

# Initial list
db2_list = []

# Read output from Db2
for line in open('/z/ZUSER/Q4Y22/drop2-db2-output.txt'):
    db2_list.append(shlex.split(line))

# Split list as needed
db2_list = db2_list[10:-2]

# Open output file
output = open('/z/ZUSER/Q4Y22/drop2-output.txt', 'a')
raw = open('/z/ZUSER/Q4Y22/drop2-raw-output.txt', 'a')

# Validate data and write valid one
for record in db2_list:
    output.write(record[0] + ',' + record[1] + ',' + record[2] + ',' + record[3] + '\n')   
    raw.write(record[0] + ',' + record[1] + ',' + record[2] + ',' + record[3] + ',' + record[4] + ',' + record[5] + '\n')

# Close output
output.close()
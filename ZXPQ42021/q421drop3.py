import shlex

# Initial list
db2_list = []
engineer_list = []

# Read output from Db2
for line in open('q421drop3-db2-output.txt'):
    db2_list.append(shlex.split(line))

# Read valid line
engineer_list = open('q421drop2-output.txt').read().splitlines()

# Split list as needed
db2_list = db2_list[10:-2]

# Open output file
output = open('q421drop3-output.txt', 'a')
format = open('q421drop3-format.txt', 'a')

# Validate data and write valid one
for record in db2_list:
    # We assume that the Db2 schema contain only matching engineers
    # https://ibmzxplore.influitive.com/forum/t/drop-1-to-drop-2-inconsistent-vendor-numbers/331/11
    #if record[3] in engineer_list:
        output.write(record[0] + ',"' + record[1] + '",' + record[2] + ',"' + record[3] + '","' + record[4] + '"\n')
        format.write(record[0] + '|"' + record[1] + '"|' + record[2] + '|"' + record[3] + '"|"' + record[4] + '"\n')

# Close output
output.close()
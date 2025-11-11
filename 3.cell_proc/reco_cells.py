# File with aborted jobs
with open('reco.txt', 'r') as f:
    indexes = [int(line.strip()) for line in f]

# Files with volumes cell, plate
with open('volumes.dat', 'r') as f:
    lines = f.readlines()

selected_lines = [lines[i] for i in indexes]

# Write selected lines to a new file
with open('volumes_reco.dat', 'w') as f:
    for line in selected_lines:
        f.write(line.strip() + '\n')
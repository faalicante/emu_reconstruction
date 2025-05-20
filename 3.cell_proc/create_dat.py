with open("volumes.dat", "w+") as file:
    for c1 in range(1, 58):
        for c2 in range(0,324):
            file.write(f"{c1},{c2}\n")
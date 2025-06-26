with open("volumes.dat", "w+") as file:
    for plate in range(1, 58):
        for cell in range(0,324):
            file.write(f"{plate},{cell}\n")
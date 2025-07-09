with open("cells.txt", "r") as file:
    lines = file.readlines()

for line in lines:
    line = line.strip()
    x_str, y_str = line.split("_")
    x, y = int(x_str), int(y_str)
    xx = int(x/10)
    yy = int(y/10)
    c = (yy - 1)*18 + xx -1
    print(c)
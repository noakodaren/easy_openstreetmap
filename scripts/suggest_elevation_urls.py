#!/usr/bin/env python3

from math import ceil,floor
from itertools import product

with open("config/bounds.txt", "r") as f:
    content = f.read()
x0,y0,x1,y1 = (float(i) for i in content.split(','))

ele_x0 = floor(x0/6 + 31)
ele_x1 = ceil(x1/6 + 31)
ele_y0 = floor(y0/4) + ord('A')
ele_y1 = ceil(y0/4) + ord('A')
for ele_x, ele_y in product(range(ele_x0, ele_x1), range(ele_y0, ele_y1)):
    # assume north of equator for now:
    print(f"https://viewfinderpanoramas.org/dem1/{chr(ele_y)}{ele_x}.zip")

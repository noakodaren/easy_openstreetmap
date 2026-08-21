#!/usr/bin/env python3
import math
import sys

with open("config/bounds.txt", "r") as f:
    content = f.read()
x0,y0,x1,y1 = (float(i) for i in content.split(','))

x = x0
y = y0

with open("config/angle.txt", "r") as f:
    content = f.read()

angle = float(content)

r = 0.00001

theta = math.radians(angle)
x2 = x + r * math.cos(theta)
y2 = y + r * math.sin(theta)

# TODO find some better method
print(f"+proj=tpeqd +lat_1={y} +lat_2={y2:.10f} +lon_1={x} +lon_2={x2} +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")

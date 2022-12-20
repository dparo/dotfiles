#!/bin/python3


import sys

def InputProcessor(begin_fnc, process_fnc, end_fnc):
    pass
    



class MeanTracker:
    def __init__(self):
        self.cnt = 0
        self.amnt = 0;

keys = []
d = {}


for line in sys.stdin:
    s = line.split("\t")

    # Remove Trailing and Leading Whitespaces
    for i in range(len(s)):
        s[i].rstrip()
        s[i].lstrip()

    if not s[0] in keys:
        keys.append(s[0])
    if not s[0] in d:
        d[s[0]] = MeanTracker()

    m = d[s[0]]
    m.amnt += float(s[1])
    m.cnt += 1;

for k in keys:
    m = d[k]
    print("mean(" + k + ") = " + str(m.amnt / m.cnt))

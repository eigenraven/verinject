#!/usr/bin/env python3

from random import randrange

lines = 256

mema = open('memory_a.mem', 'w')
memb = open('memory_b.mem', 'w')

rgen = lambda: randrange(0, 2**32-1)

for _ in range(lines):
    mema.write("%08x\n"%(rgen(),))
    memb.write("%08x\n"%(rgen(),))

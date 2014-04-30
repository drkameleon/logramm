#!/usr/bin/python

import sys

def facto(x):
	if x<=2:
		return 1
	return x*facto(x-1);

print facto(int(sys.argv[1]))
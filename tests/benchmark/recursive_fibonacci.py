#!/usr/bin/python

import sys

def fibo(x):
	if x<=1:
		return 1
	return fibo(x-1)+fibo(x-2);

print fibo(int(sys.argv[1]))
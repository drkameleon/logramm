#!/usr/bin/python

import sys

def fibo(x):
	if x<=1:
		return 1
	f=1
	fp=1
	i=1

	while (i<x):
		temp=f
		f += fp
		fp = temp
		i += 1

	return f

print fibo(int(sys.argv[1]))
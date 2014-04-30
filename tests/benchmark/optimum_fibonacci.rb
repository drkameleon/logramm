#!/usr/bin/ruby
def fibo(x)
	if x<=1
		return x
	end
	f=1
	fp=1
	i=1

	while i<x
		temp = f
		f += fp
		fp = temp
		i+=1
	end
	return f
end

puts fibo(ARGV[0].to_i)
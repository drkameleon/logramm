#!/usr/bin/ruby
def fibo(x)
	if x<=1
		return 1
	end
	return fibo(x-1)+fibo(x-2);
end

puts fibo(ARGV[0].to_i)
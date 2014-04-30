#!/usr/bin/ruby
def facto(x)
	if x<=2
		return 1
	end
	return x*facto(x-1);
end

i=0
while i<10000
	facto(ARGV[0].to_i)
	i+=1
end
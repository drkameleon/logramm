#!/usr/bin/ruby
def facto(x)
	if x<=2
		return 1
	end
	return x*facto(x-1);
end

puts facto(ARGV[0].to_i)
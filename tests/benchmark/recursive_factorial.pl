#!/usr/bin/perl

sub facto
{
	my ($x) = @_;

	if ($x<=2)
	{
		return 1;
	}
	return $x*facto($x-1);
}

print facto(@ARGV[0]+0)." ";


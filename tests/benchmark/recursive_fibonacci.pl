#!/usr/bin/perl

sub fibo
{
	my ($x) = @_;

	if ($x<=1)
	{
		return 1;
	}
	return fibo($x-1)+fibo($x-2);
}

print fibo(@ARGV[0]+0)." ";


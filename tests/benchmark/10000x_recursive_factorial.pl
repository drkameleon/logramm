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

$i=0;

while ($i<10000)
{
	facto(@ARGV[0]+0)." ";
	$i+=1;
}


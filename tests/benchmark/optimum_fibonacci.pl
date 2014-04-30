#!/usr/bin/perl

sub fibo
{
	my ($x) = @_;

	if ($x<=1) {
		return $x;
	}
	
	$f=1;
	$fp=1;
	$i=1;

	while ($i<$x)
	{
		$temp = $f;
		$f += $fp;
		$fp = $temp;
		$i+=1;
	}
	return $f;
}

print fibo(@ARGV[0]+0)." ";


#!/usr/bin/php
<?php
function fibo($x)
{
	if ($x<=1) return $x;

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

echo fibo($argv[1]);
?>


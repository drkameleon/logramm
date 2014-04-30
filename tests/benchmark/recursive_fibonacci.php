#!/usr/bin/php
<?php
function fibo($x)
{
	if ($x<=1)
		return 1;
	return fibo($x-1)+fibo($x-2);
}

echo fibo($argv[1]);
?>


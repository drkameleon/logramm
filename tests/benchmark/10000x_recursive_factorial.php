#!/usr/bin/php
<?php
function facto($x)
{
	if ($x<=2)
		return 1;
	return $x*facto($x-1);
}

$i=0;

while ($i<10000)
{
	facto($argv[1]);
	$i+=1;
}
?>


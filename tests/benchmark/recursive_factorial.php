#!/usr/bin/php
<?php
function facto($x)
{
	if ($x<=2)
		return 1;
	return $x*facto($x-1);
}

echo facto($argv[1]);
?>


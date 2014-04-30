<?php 
	function getFiles($name)
	{
		$files = array($name);

		$packageInfo = json_decode(file_get_contents("list/$name.json"),true);

		if ($packageInfo)
		{
			foreach ($packageInfo["deps"] as $dep)
			{
				$files = array_merge($files, getFiles($dep));
			}
		}

		return $files;
	}

	$q = $_GET['query'];
	$a = $_GET['action'];

	$packageInfo = json_decode(file_get_contents("list/$q.json"),true);

	if (!isset($packageInfo)) 
	{
		echo "Package '$q' not found.";
	}

	if ($a=="info")
	{
		echo $packageInfo["title"]." - ".$packageInfo["version"]."\n";
		echo $packageInfo["info"]."\n";
		echo $packageInfo["copyright"]."\n";
	}
	elseif ($a=="files")
	{
		$fileList = getFiles($q);
		foreach ($fileList as $f)
		{
			echo "$f\n";
		}
	}
	elseif ($a=="get")
	{
	    $yourfile = "/var/www/packages/list/$q.lgm";
	    $contents = file_get_contents($yourfile);

	    echo $contents;
	}
?>
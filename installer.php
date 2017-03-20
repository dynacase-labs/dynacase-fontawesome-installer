#!/usr/bin/env php

<?php

$WIFF_CONTEXT_ROOT = getenv("WIFF_CONTEXT_ROOT");

$libPath = $WIFF_CONTEXT_ROOT.DIRECTORY_SEPARATOR.'lib';

if (!$WIFF_CONTEXT_ROOT || !is_dir($libPath)) {
    echo("The context lib is not a valid path : $libPath\n");
    exit(10);
}

$pathToZip = realpath($argv[1]);

if (!is_file($pathToZip)) {
    echo("The path is not a valid filename : $pathToZip\n");
    exit(20);
}

$zip = new ZipArchive;
$res = $zip->open($pathToZip);

if ($res === true) {
    $zip->extractTo($libPath);
    $zip->close();
} else {
    echo("Unable to open : $pathToZip\n");
    exit(30);
}
exit(0);
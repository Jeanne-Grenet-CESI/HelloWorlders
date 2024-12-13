<?php

function loadClass($classe)
{
    $ds = DIRECTORY_SEPARATOR;
    $dir = $_SERVER["DOCUMENT_ROOT"] . "$ds..";

    $className = str_replace('\\', $ds, $classe);
    $file = "{$dir}{$ds}{$className}.php";
    if (is_readable($file)) require_once $file;
}

spl_autoload_register('loadClass');


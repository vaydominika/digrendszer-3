#!/usr/bin/php
<?php

function isWindows()
{
    return defined('PHP_WINDOWS_VERSION_BUILD');
}

  function get_home()
  {
    if (false !== ($home = getenv('HOME')))
    {
      return $home;
    }
    if (/*isWindows() &&*/ false !== ($home = getenv('USERPROFILE')))
    {
      return $home;
    }
    if (function_exists('posix_getuid') && function_exists('posix_getpwuid')) {
      $info = posix_getpwuid(posix_getuid());
      return $info['dir'];
    }
    return "";
  }


function sys_inc()
{
    $i= 0;
    $d= "./";
    while ($i<6)
    {
        if (file_exists($d.".version"))
        {
            return $d."/sw/lib";
            break;
        }
        $d= "../".$d;
        $i++;
    }
    $d= get_home();
    if (file_exists($d."/p12tool") && file_exists($d."/p12tool/include"))
        return $d."/p12tool/include";
    return "";
}


function find_version()
{
    $i= 0;
    $d= "./";
    while ($i<6)
    {
        if (file_exists($d.".version"))
        {
            return $d.".version";
            break;
        }
        $d= "../".$d;
        $i++;
    }
    return "";
}

function gen_version()
{
    $vf= find_version();
    if ($vf == '')
        return "";
    $v= file_get_contents($vf);
    if ($v == '')
        return "";
    $v1= strtok($v, ".\n");
    $v2= strtok(".\n");
    $v3= strtok(".\n");

    if ($v1!='') echo "`define VER_MAIN $v1\n";
    if ($v2!='') echo "`define VER_SUB  $v2\n";
    if ($v3!='') echo "`define VER_REL  $v3\n";

    return $v;
}


if (isset($argv[0]))
{
    for ($i=1; $i<$argc; $i++)
    {
        if ($argv[$i] == "-h")
        {
            echo get_home()."\n";
        }
        else if ($argv[$i] == "-si")
        {
            echo sys_inc()."\n";
        }
        else if (($argv[$i] == "-gv") || ($argv[$i] == "-vg"))
        {
            gen_version();
        }
    }
}
  
?>

#!/usr/bin/php
<?PHP
require_once("/usr/local/emhttp/plugins/community.applications/include/xmlHelpers.php");
require_once("/usr/local/emhttp/plugins/community.applications/include/helpers.php");

@unlink("/boot/dvb-builds.txt");

$xmlRaw = file_get_contents("https://lsio.ams3.digitaloceanspaces.com/?max-keys=500000");
$o = TypeConverter::xmlToArray($xmlRaw,TypeConverter::XML_GROUP);
foreach ($o['Contents'] as $test) {
  if (startsWith($test['Key'],"unraid-dvb-old-builds")) {
    continue;
  }
  if (startsWith($test['Key'],"unraid-dvb")) {
    $folder[dirname($test['Key'])] = true;
  }
}
foreach (array_keys($folder) as $path) {
  file_put_contents("/boot/dvb-builds.txt﻿","https://lsio.ams3.digitaloceanspaces.com/$path\n",FILE_APPEND);
}
?>

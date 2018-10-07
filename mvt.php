<?php
// connect to postgis database
include('../../oma.sk/connect.php');

function getcgi($name, $default=NULL, $extra='') {
    $r = preg_replace("/[^A-Za-z0-9\-_.,$extra]/", "", $_GET[$name] );
        if(strlen($r)<1) return $default;
        if($r=='undefined') return $default;
        return $r;
}

$way = 'way';
$l = 2000; // limit

$tile = strtr(getcgi('tile', NULL, '\/'), array('/' => ','));

$q1 = "select st_asmvt(q, 'entrances', 4096, 'geom') as mvt from 
  (select st_AsMvtGeom($way, BBox($tile), 4096, 256, true) as geom from parks_entrances where $way && BBox($tile) limit $l) as q";

$q2 = "select st_asmvt(q, 'parks', 4096, 'geom') as mvt from
  (select st_AsMvtGeom($way, BBox($tile), 4096, 256, true) as geom, name, landuse, plocha from parks where $way && BBox($tile) limit $l) as q";

$q = "$q1 union $q2";
//$q = $q2;
$res = pg_query($q); $out = '';
//if(strlen($r['mvt']) < 10) { header("HTTP/1.1 404"); header("Access-Control-Allow-Origin: *"); echo pg_last_error(); die(); }

header("Access-Control-Allow-Origin: *"); header('Content-Type: application/x-protobuf'); //header('Content-Encoding: gzip');
////header('Expires: '.gmdate('D, d M Y H:i:s \G\M\T', time() + (2*24*60 * 60)));
header("Content-Disposition: attachment");
while($r = pg_fetch_assoc($res)) echo pg_unescape_bytea($r['mvt']);

//file_put_contents("/home/izsk/weby/tiles/mvt/".strtr($tile, array(',' => '/')).".pbf", gzcompress($r['mvt']));


?>

CREATE OR REPLACE FUNCTION www.bbox(zoom integer, x integer, y integer)
 RETURNS geometry
 LANGUAGE plpgsql
 IMMUTABLE PARALLEL SAFE
AS $function$
DECLARE
 n float; E float = 2.7182818284; tt float;
 lat float;
 lon float;
BEGIN
  -- vrati NW, +1 aby bol druhy koniec
  n = 1.0*power(2.0, zoom);
  tt=pi() - (2.0 * pi() * y) / n;
  lat = degrees(atan( (1 - power(E, -2*tt)) / (2 * power(E, -tt)) ));
  lon = 360.0 * x / n - 180; --ok
  tt=pi() - (2.0 * pi() * (1+y)) / n;
  return ST_MakeEnvelope( lon, lat, 360.0 * (1+x) / n - 180, degrees(atan( (1 - power(E, -2*tt)) / (2 * power(E, -tt)) )), 4326);
END;
$function$


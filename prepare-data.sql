
drop table if exists parks;
create table www.parks as select osm_id, name, round(st_area(geography(way))) plocha, way,
case when leisure='park' then 'park' when landuse in ('forest') or "natural" = 'wood' then 'forest' when landuse in ('meadow','grass','village_green') then 'grass' end as landuse
from fresh_osm_polygon where (leisure='park' or landuse is not null or "natural" in ('wood','tree')) 
and ( exist(tags, 'access') = false or tags->'access' not in ('private','no') )
and st_area(geography(way)) > 1000;
delete from parks where landuse is null;

-- intersect with higways to find entrances

drop table if exists parks_entrances;
create table www.parks_entrances as 
select parks.osm_id, st_intersection(l.way, st_exteriorring(parks.way)) as way
from parks, fresh_osm_line as l
where l.highway is not null and st_intersects(l.way, parks.way)
;



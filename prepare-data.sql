
drop table if exists parks;
-- '{park,cintorin,futbal}'
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
where l.highway is not null
 and (exist(tags,'bridge') = false or tags->'bridge' in ('no'))
 and (exist(tags,'tunnel') = false or tags->'tunnel' in ('no'))
 and st_intersects(l.way, parks.way)
;


drop table if exists parks_trees;
-- create table www.parks_trees as select osm_id, name, way from fresh_osm_point where "natural"='tree';

create table www.parks_trees as select osm_id, name, case when typy && '{chraneny-strom}' then 'chraneny' else 'strom' end as typ, case when name not like '%strom' then name ||' ' else '' end || popis_maly || ', <a href="https://poi.oma.sk/'||t||osm_id||'">viac</a>' as description, geometry(way) as way from poi where typy && '{strom}';


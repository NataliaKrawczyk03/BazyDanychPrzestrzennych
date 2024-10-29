--2.Utwórz pustą bazę danych
CREATE DATABASE city;
--3.Dodaj funkcjonalności PostGIS’a do bazy
CREATE EXTENSION postgis;

--4.Na podstawie poniższej mapy utwórz trzy tabele: buildings (id, geometry, name), roads 
--(id, geometry, name), poi (id, geometry, name). 
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(POLYGON, 0),
	name VARCHAR(255)
);
CREATE TABLE roads (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(LINESTRING, 0),
    name VARCHAR(255)
);
CREATE TABLE poi (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(POINT, 0),
    name VARCHAR(255)
);

--5.Współrzędne obiektów oraz nazwy (np. BuildingA) należy odczytać z mapki umieszczonej 
--poniżej. Układ współrzędnych ustaw jako niezdefiniowany. 
INSERT INTO buildings (geometry, name)
VALUES 
    (ST_PolygonFromText('POLYGON((8 4, 10.5 4, 8 1.5, 10.5 1.5, 8 4))', 0),'BuildingA'),
    (ST_PolygonFromText('POLYGON((4 5, 6 5,4 7,6 7, 4 5))', 0),'BuildingB'),
	(ST_PolygonFromText('POLYGON((3 8,5 8, 3 6,5 6,3 8))', 0),'BuildingC'),
	(ST_PolygonFromText('POLYGON((9 9, 10 9, 9 8,10 8, 9 9))', 0),'BuildingD'),
	(ST_PolygonFromText('POLYGON((1 2, 2 2, 1 1,2 1, 1 2))', 0),'BuildingF');
INSERT INTO roads(geometry,name)
VALUES
	(ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)',0),'RoadX'),
	(ST_GeomFromText('LINESTRING(7.5 10.5, 7.5 0)',0),'RoadY');
INSERT INTO poi (geometry, name)
VALUES 
    (ST_Point(1, 3.5)::GEOMETRY(Point, 0),'G'),
	(ST_Point(5.5, 1.5)::GEOMETRY(Point, 0),'H'),
	(ST_Point(9.5, 6) ::GEOMETRY(Point, 0),'I'),
	(ST_Point(6.5, 6)::GEOMETRY(Point, 0),'J'),
	(ST_Point(6, 9.5)::GEOMETRY(Point, 0),'K');

--6a.Wyznacz całkowitą długość dróg w analizowanym mieście.
SELECT SUM(ST_Length(geometry)) AS total_length
FROM roads;

--6b.Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego 
--budynek o nazwie BuildingA.  
SELECT 
	ST_AsText(geometry) AS geometry_wkt,
    ST_Area(geometry) AS area,
    ST_Perimeter(geometry) AS perimeter
FROM buildings
WHERE name='BuildingA'

--6c.Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki.  
--Wyniki posortuj alfabetycznie.  
SELECT name, ST_Area(geometry) AS area
FROM buildings
ORDER BY name ;

--6d.Wypisz nazwy i obwody 2 budynków o największej powierzchni. 
SELECT name, ST_Perimeter(geometry) AS perimeter
FROM buildings
LIMIT 2;

--6e.Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem K. 
SELECT 
    ST_Distance(
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        (SELECT geometry FROM poi WHERE name = 'K')
    ) AS shortest_distance;

--6f. Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w odległości 
--większej niż 0.5 od budynku BuildingB. 
SELECT 
    ST_Area(ST_Difference(
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        (SELECT geometry FROM buildings WHERE name = 'BuildingB')
    )) AS area_outside_distance
WHERE ST_Distance(
        (SELECT geometry FROM buildings WHERE name = 'BuildingC'),
        (SELECT geometry FROM buildings WHERE name = 'BuildingB')
    ) > 0.5;

--6g.Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi  
--o nazwie RoadX. 
SELECT 
    b.name
FROM 
    buildings b
JOIN 
    roads r ON r.name = 'RoadX'
WHERE 
    ST_Y(ST_Centroid(b.geometry)) > ST_YMax(ST_Envelope(r.geometry));

--6h.Oblicz pole powierzchni tych części budynku BuildingC i poligonu o współrzędnych  
--(4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch obiektów. 
WITH polygon AS (
    SELECT ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 0) AS geom
)
SELECT 
    ST_Area(ST_Union(
        ST_Difference((SELECT geometry FROM buildings WHERE name = 'BuildingC'), (SELECT geom FROM polygon))
    )) AS area_non_common;





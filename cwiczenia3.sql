--1.Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana
 --pomiędzy 2018 a 2019).
SELECT b2019.polygon_id, b2019.geom
FROM kar_buildings_2019 b2019
LEFT JOIN kar_buildings_2018 b2018
ON ST_Equals(b2018.geom, b2019.geom)
WHERE b2018.gid IS NULL;
--budynki gdzie nastapila zmiana geometrii w przeciagu roku

--2. Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub
 --wybudowanych budynków, które znalezione zostały w zadaniu 1. Policz je wg ich kategorii.
WITH new_or_renovated_buildings AS (
    SELECT b2019.polygon_id, b2019.geom
    FROM kar_buildings_2019 b2019
    LEFT JOIN kar_buildings_2018 b2018
    ON ST_Equals(b2018.geom, b2019.geom)
    WHERE b2018.polygon_id IS NULL
),	--nowe lub wyremontowane budynki
new_poi AS (
    SELECT poi2019.poi_id, poi2019.geom, poi2019.type
    FROM kar_poi_2019 poi2019
    LEFT JOIN kar_poi_2018 poi2018
    ON ST_Equals(poi2018.geom, poi2019.geom)
    WHERE poi2018.poi_id IS NULL
)	--nowe punkty
SELECT 
    COUNT(*) AS poi_count
FROM new_poi
JOIN new_or_renovated_buildings b
ON ST_Distance(new_poi.geom, b.geom) <= 500;

--3.Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli
--T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini

SELECT DISTINCT ST_SRID(geom) FROM kar_streets_2019; -- brak ukladu

UPDATE kar_streets_2019
SET geom = ST_SetSRID(geom, 4326); --ustalenie ukladu na podstawie pliku prj

CREATE TABLE streets_reprojected AS
SELECT 
    *  
FROM 
    kar_streets_2019;	--nowa tebela

UPDATE streets_reprojected
SET geom = ST_Transform(geom, 3068);	--zamiana ukladu

SELECT DISTINCT ST_SRID(geom) FROM streets_reprojected;

--4.Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.
CREATE TABLE input_points (
    id SERIAL PRIMARY KEY,
    geometry GEOMETRY(POINT, 0)
);

INSERT INTO input_points (geometry)
VALUES 
    (ST_Point(8.36093, 49.03174)::GEOMETRY(Point, 0)),
	(ST_Point(8.39876, 49.00644)::GEOMETRY(Point, 0));

--5.Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych
 --DHDN.Berlin/Cassini.
UPDATE input_points
SET geometry = ST_Transform(ST_SetSRID(geometry, 4326), 3068);

SELECT DISTINCT ST_SRID(geometry) FROM input_points;

--6.Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej
--z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. 
--Dokonaj reprojekcji geometrii, aby była zgodna z resztą tabel.
UPDATE kar_streetnode_2019
SET geom = ST_Transform(ST_SetSRID(geom, 4326), 3068);	--zamiana geometrii

SELECT ST_MakeLine(geometry) AS line_geom
INTO TEMP TABLE temp_line
FROM input_points;	--linia utworzona z punktow

SELECT n.*, ST_Distance(n.geom, l.line_geom) AS distance
FROM kar_streetnode_2019 n
CROSS JOIN temp_line l
WHERE ST_Distance(n.geom, l.line_geom) <= 200;

--7.Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się
--w odległości 300 m od parków (LAND_USE_A).
UPDATE kar_poi_2019
SET geom = ST_Transform(ST_SetSRID(geom, 4326), 3068);

UPDATE kar_landusea_2019
SET geom = ST_Transform(ST_SetSRID(geom, 4326), 3068);

SELECT COUNT(s.*) AS sporting_goods_count
FROM kar_poi_2019 s
JOIN kar_landusea_2019 p
ON ST_Distance(s.geom, p.geom) <= 300
WHERE s.type = 'Sporting Goods Store';

--8.Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapisz
 --znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.
UPDATE kar_waterlines_2019
SET geom = ST_SetSRID(geom, 4326);

UPDATE kar_railways_2019
SET geom = ST_SetSRID(geom, 4326);

SELECT ST_Intersection(r.geom, w.geom) AS geom
INTO T2019_KAR_BRIDGES
FROM kar_railways_2019 r
JOIN kar_waterlines_2019 w
ON ST_Intersects(r.geom, w.geom);

SELECT *
FROM T2019_KAR_BRIDGES;
--1.Utwórz tabelę obiekty. W tabeli umieść nazwy i geometrie obiektów przedstawionych poniżej. 
--Układ odniesienia ustal jako niezdefiniowany.

CREATE TABLE obiekty (
    id SERIAL PRIMARY KEY,            
    nazwa VARCHAR(50),                
    geometria GEOMETRY,     
    typ_geometrii VARCHAR(30)    
	);

INSERT INTO obiekty (nazwa, geometria, typ_geometrii)
VALUES 
    ('obiekt1', ST_Collect(ARRAY[
        ST_GeomFromText('LINESTRING(0 1, 1 1)', 0),                       -- linia
        ST_GeomFromText('CIRCULARSTRING(1 1, 2 0, 3 1)', 0),               -- łuk 1
        ST_GeomFromText('CIRCULARSTRING(3 1, 4 2, 5 1)', 0),               -- łuk 2
        ST_GeomFromText('LINESTRING(5 1, 6 1)', 0)                         -- linia
    ]),
    'linie i luki'),
    
    ('obiekt2', ST_Collect(ARRAY[
        ST_GeomFromText('LINESTRING(10 6, 14 6)', 0),                     -- linia 1
        ST_GeomFromText('CIRCULARSTRING(14 6, 16 4, 14 2)', 0),            -- łuk 1
        ST_GeomFromText('CIRCULARSTRING(14 2, 12 0, 10 2)', 0),            -- łuk 2
        ST_GeomFromText('LINESTRING(10 2, 10 6)', 0),                     -- linia 2
        ST_GeomFromText('CIRCULARSTRING(11 2, 12 3, 13 2)', 0),            -- łuk 3
        ST_GeomFromText('CIRCULARSTRING(13 2, 12 1, 11 2)', 0)             -- łuk 4
    ]),
    'obiekt zamkniety'),

    ('obiekt3', ST_Collect(ARRAY[
        ST_GeomFromText('LINESTRING(7 15, 10 17)', 0),                     -- linia 1
        ST_GeomFromText('LINESTRING(10 17, 12 13)', 0),                    -- linia 2
        ST_GeomFromText('LINESTRING(12 13, 7 15)', 0)                      -- linia 3
    ]),
    'trójkąt'),

    ('obiekt4', ST_Collect(ARRAY[
        ST_GeomFromText('LINESTRING(20 20, 25 25)', 0),                    -- linia 1
        ST_GeomFromText('LINESTRING(25 25, 27 24)', 0),                    -- linia 2
        ST_GeomFromText('LINESTRING(27 24, 25 22)', 0),                    -- linia 3
        ST_GeomFromText('LINESTRING(25 22, 26 21)', 0),                    -- linia 4
        ST_GeomFromText('LINESTRING(26 21, 22 19)', 0),                    -- linia 5
        ST_GeomFromText('LINESTRING(22 19, 20.5 19.5)', 0)                 -- linia 6
    ]),
    'obiekt z linii'),

    ('obiekt5', ST_Collect(ARRAY[
        ST_SetSRID(ST_MakePoint(30, 30, 59), 0),                           -- punkt 1
        ST_SetSRID(ST_MakePoint(38, 32, 234), 0)                           -- punkt 2
    ]),
    'dwa punkty 3d'),

    ('obiekt6', ST_Collect(ARRAY[
        ST_GeomFromText('LINESTRING(1 1, 3 2)', 0),                         -- linia
        ST_SetSRID(ST_MakePoint(4, 2), 0)                                   -- punkt
    ]),
    'linia i punkt');

--2.Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który został utworzony wokół 
--najkrótszej linii łączącej obiekt 3 i 4. 
WITH najkrotsza_linia AS (
    SELECT ST_ShortestLine(o1.geometria, o2.geometria) AS najkrotsza_linia
    FROM obiekty o1, obiekty o2
    WHERE o1.nazwa = 'obiekt3' AND o2.nazwa = 'obiekt4'
),
bufor AS (
    SELECT ST_Buffer(najkrotsza_linia, 5) AS geometria_bufora
    FROM najkrotsza_linia
)
SELECT ST_Area(geometria_bufora) AS pole_powierzchni_bufora
FROM bufor;

--3.Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby można było wykonać to 
--zadanie? Zapewnij te warunki.
--aby moc utworzyc poligon, obiekt musi byc zamkniety
UPDATE obiekty
SET geometria = ST_MakePolygon(
    ST_MakeLine(
        ARRAY[
            ST_GeomFromText('POINT(20 20)'), 
            ST_GeomFromText('POINT(25 25)'), 
            ST_GeomFromText('POINT(27 24)'), 
            ST_GeomFromText('POINT(25 22)'), 
            ST_GeomFromText('POINT(26 21)'), 
            ST_GeomFromText('POINT(22 19)'), 
            ST_GeomFromText('POINT(20.5 19.5)'), 
            ST_GeomFromText('POINT(20 20)') -- zamknięcie linii 
        ])
)
WHERE nazwa = 'obiekt4';

--4.W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4. 
INSERT INTO obiekty (nazwa, geometria, typ_geometrii)
SELECT 
    'obiekt7', 
    ST_Union(o3.geometria, o4.geometria) AS geometria,
    'zlozony z obiektu 3 i 4' 
FROM 
    obiekty o3, 
    obiekty o4
WHERE 
    o3.nazwa = 'obiekt3'
    AND o4.nazwa = 'obiekt4';

--5.Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone 
--wokół obiektów nie zawierających łuków. 
SELECT 
    SUM(ST_Area(ST_Buffer(geometria, 5))) AS total_area
FROM 
    obiekty
WHERE 
    NOT ST_HasArc(geometria);





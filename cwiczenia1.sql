USE turniej;
--1.Wyświetl id meczu (kolumna matchid) oraz strzelca (kolumna player) każdej bramki zdobytej 
--przez Polskę. Aby znaleźć mecze rozgrywane przez Polskę użyj kolumny teamid oraz nazwy 
--'POL Potrzebne dane znajdują się w tabeli gole. 
SELECT matchid, player
FROM gole
WHERE teamid='POL';

--2.Z tabeli mecze wybierz wiersz odpowiadający bramce strzelonej przez Jakuba 
--Błaszczykowskiego. W warunku użyj id meczu 1004. 
SELECT *
FROM mecze
WHERE id=1004

--3.Zmodyfikuj poniższe zapytanie tak aby wyświetlało imię i nazwisko zawodnika, jego drużynę, 
--stadion oraz datę zdobycia każdej bramki dla Polski
SELECT player,teamid,stadium,mdate 
FROM mecze 
JOIN gole ON (id=matchid)
WHERE teamid='POL';

--4.Zmodyfikuj kwerendę z poprzedniego zadania tak aby wyświetlała nazwę obu drużyn 
--(kolumny team1, team2) oraz zawodnika (kolumna player) dla każdej bramki zdobytej 
--przez zawodnika o imieniu Mario. 
SELECT team1,team2,player 
FROM mecze 
JOIN gole ON (id=matchid)
WHERE player LIKE 'Mario%';

--5.Tabela drużyny zawiera informację o wszystkich zespołach narodowych wraz z nazwiskiem 
--trenera. Wyświetl nazwę zawodnika (kolumna player), id zespołu (teamid), trenera (coach) 
--oraz czas zdobycia bramki (gtime) dla wszystkich goli strzelonych w pierwszych 10 minutach 
--meczu (gtime<=10). 
SELECT player,teamid,coach,gtime
FROM gole
JOIN druzyny ON (teamid=id)
WHERE gtime<=10;

--6.Wyświetl nazwę drużyny, której trenerem był Franciszek Smuda oraz daty rozgrywanych przez 
--nią spotkań. 
SELECT teamname,mdate
FROM druzyny
JOIN mecze ON (druzyny.id=team1 OR druzyny.id=team2)
WHERE coach LIKE 'Franciszek Smuda';

--7.Wyświetl zawodników (player), którzy strzelili gola na stadionie w Warszawie  
SELECT player
FROM gole
JOIN mecze ON (matchid=id)
WHERE stadium ='National Stadium, Warsaw'

--8.Poniższa kwerenda wyświetla wszystkie gole zdobyte w meczu Niemcy - Grecja.  
-Zmodyfikuj kwerendę tak aby wyświetlała nazwy wszystkich zawodników, którzy strzelili 
-bramkę przeciwko Niemcom.  
SELECT player, gtime
FROM mecze 
JOIN gole ON matchid = id 
WHERE (team1='GER' OR team2='GER') AND (teamid NOT LIKE 'GER')

--9.Wyświetl nazwę drużyny oraz liczbę zdobytych przez nią goli. Wynik posortuj malejąco 
--według zdobytych goli. 
SELECT id, COUNT(gtime) AS liczba_goli
FROM gole
JOIN druzyny ON (teamid=id)
GROUP BY id
ORDER BY liczba_goli DESC;

--10.Wyświetl nazwę stadionu oraz liczbę zdobytych na nim goli. Wynik posortuj malejąco według 
--zdobytych goli. 
SELECT stadium,COUNT(gtime) AS liczba_goli
FROM mecze
JOIN gole ON (id = matchid)
GROUP BY stadium
ORDER BY liczba_goli DESC;





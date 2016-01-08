# Searches

\o search.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$submit'
GROUP BY 1
ORDER BY 1;


# Scheduling

\o scheduling/adds.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'add' = 'true'
GROUP BY 1
ORDER BY 1;

\o scheduling/deletes.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'add' = 'false'
GROUP BY 1
ORDER BY 1;

\o scheduling/re-adds.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'readd' = 'true'
GROUP BY 1
ORDER BY 1;


# Search-by-clicks

\o searchclicks/instructor.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'name' = 'instructor'
GROUP BY 1
ORDER BY 1;

\o searchclicks/block.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'name' = 'block'
GROUP BY 1
ORDER BY 1;

\o searchclicks/prerequisites.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'name' = 'prerequisites'
GROUP BY 1
ORDER BY 1;

\o searchclicks/crosslisted.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'name' = 'crosslisted'
GROUP BY 1
ORDER BY 1;


# Exports

\o exports/ics.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'name' = 'export-ics'
GROUP BY 1
ORDER BY 1;

\o exports/gcal.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'name' = 'export-gcal'
GROUP BY 1
ORDER BY 1;

\o exports/image.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'name' = 'export-image'
GROUP BY 1
ORDER BY 1;


# Showing subcourses

\o subcourseson.txt;
SELECT date_trunc('day', time) AS "Day", count(*)
FROM ahoy_events
WHERE name = '$click' AND properties->'hide' = 'false'
GROUP BY 1
ORDER BY 1;
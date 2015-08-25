-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP DATABASE IF EXISTS tournament;
CREATE DATABASE tournament;
\c tournament;

-- create the player table

CREATE TABLE IF NOT EXISTS players (
    id SERIAL PRIMARY KEY,
    name text NOT NULL
);

-- create the games table with matching results

CREATE TABLE IF NOT EXISTS games (
    game_id SERIAL PRIMARY KEY,
    winner integer REFERENCES players(id),
    loser integer REFERENCES players(id),
    CHECK(winner!=loser),
    UNIQUE(winner, loser)
);


-- Create standing view ordered by number of wins desc.

CREATE OR REPLACE VIEW standings AS
SELECT A.id, A.name,
       CASE WHEN B.wins is Null THEN 0
            ELSE B.wins END,
       CASE WHEN B.matches is Null THEN 0
            ELSE B.matches END
FROM
players AS A
LEFT JOIN
(
    SELECT
        COALESCE(win_table.win_id, lose_table.loser_id) AS id,
        COALESCE(win_table.wins,0) AS wins,
        (CASE WHEN win_table.wins is Null THEN 0
            ELSE win_table.wins END)+
        (CASE WHEN lose_table.loses is Null THEN 0
            ELSE lose_table.loses END) AS matches
    FROM
        (SELECT
             players.id AS win_id,
             COUNT(*) AS wins
        FROM players JOIN games
        ON players.id = games.winner
        GROUP BY players.id) AS win_table
    FULL OUTER JOIN
        (SELECT
             players.id AS loser_id,
             COUNT(*) AS loses
         FROM players JOIN games
         ON players.id = games.loser
         GROUP BY players.id) AS lose_table
    ON win_table.win_id = lose_table.loser_id
) AS B
ON A.id = B.id
ORDER BY wins DESC;
    
    



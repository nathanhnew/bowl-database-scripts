\set ON_ERROR_STOP true;

CREATE SCHEMA bowl;
CREATE SCHEMA league;
GRANT USAGE ON SCHEMA league TO app;
GRANT USAGE ON SCHEMA bowl TO app;
ALTER DEFAULT PRIVILEGES IN SCHEMA league GRANT ALL ON TABLES TO app; 
ALTER DEFAULT PRIVILEGES IN SCHEMA bowl GRANT ALL ON TABLES TO app; 
ALTER DEFAULT PRIVILEGES IN SCHEMA league GRANT ALL ON SEQUENCES TO app; 
ALTER DEFAULT PRIVILEGES IN SCHEMA bowl GRANT ALL ON SEQUENCES TO app; 
ALTER DEFAULT PRIVILEGES IN SCHEMA league GRANT ALL ON FUNCTIONS TO app; 
ALTER DEFAULT PRIVILEGES IN SCHEMA bowl GRANT ALL ON FUNCTIONS TO app; 

-- Bowl Schema
CREATE TABLE bowl.bowl(
    id  SERIAL PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    logo TEXT,
    location_city TEXT,
    location_region TEXT,
    location_country TEXT
);
CREATE INDEX bowl_name_idx ON bowl.bowl(name);

CREATE TABLE bowl.bowl_game(
    id SERIAL PRIMARY KEY NOT NULL,
    bowl_id INT NOT NULL,
    date timestamp NOT NULL,
    CONSTRAINT fk_bowl FOREIGN KEY(bowl_id) REFERENCES bowl.bowl(id)
);
CREATE INDEX bowl_game_ix ON bowl.bowl_game(bowl_id, date);

CREATE TABLE bowl.team(
    id SERIAL PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    location_city TEXT,
    location_region TEXT,
    location_country TEXT,
    mascot TEXT,
    logo TEXT
);
CREATE INDEX team_name_ix ON bowl.team(name);
CREATE INDEX team_mascot_ix ON bowl.team(mascot);

CREATE TABLE bowl.team_rival(
    id SERIAL PRIMARY KEY NOT NULL,
    team_id INT NOT NULL,
    rival_id INT NOT NULL,
    CONSTRAINT fk_team FOREIGN KEY(team_id) REFERENCES bowl.team(id),
    CONSTRAINT fk_rival FOREIGN KEY(rival_id) REFERENCES bowl.team(id)
);
CREATE INDEX team_rival_ix ON bowl.team_rival(team_id, rival_id);
CREATE INDEX team_rival_rev_ix ON bowl.team_rival(rival_id, team_id);

CREATE TABLE bowl.bowl_game_team(
    id SERIAL PRIMARY KEY NOT NULL,
    bowl_game_id INT NOT NULL,
    team_id INT NOT NULL,
    is_home BOOLEAN,
    CONSTRAINT fk_bowl_game FOREIGN KEY(bowl_game_id) REFERENCES bowl.bowl_game(id),
    CONSTRAINT fk_team FOREIGN KEY(team_id) REFERENCES bowl.team(id)
);
CREATE INDEX bowl_game_team_bowl_ix ON bowl.bowl_game_team(bowl_game_id);
CREATE INDEX bowl_game_team_ix ON bowl.bowl_game_team(team_id);

CREATE TABLE bowl.game_spread(
    id SERIAL PRIMARY KEY NOT NULL,
    favorite_id INT NOT NULL,
    spread FLOAT NOT NULL,
    date TIMESTAMP NOT NULL,
    CONSTRAINT fk_favorite FOREIGN KEY(favorite_id) REFERENCES bowl.team(id)
);
CREATE INDEX game_spread_team_ix ON bowl.game_spread(favorite_id);

-- League Schema
CREATE TABLE league.account(
    id SERIAL PRIMARY KEY NOT NULL,
    email TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    favorite_team_id INT,
    password TEXT NOT NULL,
    CONSTRAINT fk_favorite_team FOREIGN KEY(favorite_team_id) REFERENCES bowl.team(id)
);
CREATE UNIQUE INDEX account_email_ix ON league.account(email);

CREATE TABLE league.league(
    id SERIAL PRIMARY KEY NOT NULL,
    name text NOT NULL,
    admin_id INT NOT NULL,
    active BOOLEAN NOT NULL,
    CONSTRAINT fk_admin FOREIGN KEY(admin_id) REFERENCES league.account(id)
);
CREATE INDEX league_name_ix ON league(name);

CREATE TABLE league.league_season(
    id SERIAL PRIMARY KEY NOT NULL,
    league_id INT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    season INT NOT NULL,
    CONSTRAINT fk_league FOREIGN KEY(league_id) REFERENCES league.league(id)
);
CREATE INDEX league_season_league_ix ON league.league_season(league_id);
CREATE INDEX league_season_season_ix ON league.league_season(season);

CREATE TABLE league.league_season_rules(
    id SERIAL PRIMARY KEY NOT NULL,
    league_season_id INT NOT NULL,
    sum_points BOOLEAN NOT NULL DEFAULT FALSE,
    add_spread_to_points BOOLEAN NOT NULL DEFAULT FALSE,
    spread_cutoff_date TIMESTAMP,
    CONSTRAINT fk_league_season FOREIGN KEY(league_season_id) REFERENCES league.league_season(id)
);
CREATE INDEX league_season_rules_season_ix ON league.league_season_rules(league_season_id);

CREATE TABLE league.league_game(
    id SERIAL PRIMARY KEY NOT NULL,
    league_season_id INT NOT NULL,
    bowl_game_id INT NOT NULL,
    CONSTRAINT fk_league_season FOREIGN KEY(league_season_id) REFERENCES league.league_season(id),
    CONSTRAINT fk_bowl_game FOREIGN KEY(bowl_game_id) REFERENCES bowl.bowl_game(id)
);
CREATE INDEX league_game_season_ix ON league.league_game(league_season_id);
CREATE INDEX league_game_bowl_ix ON league.league_game(bowl_game_id);

CREATE TABLE league.pick(
    id SERIAL PRIMARY KEY NOT NULL,
    league_game_id INT NOT NULL,
    account_id INT NOT NULL,
    winner INT NOT NULL,
    value INT NOT NULL,
    CONSTRAINT fk_league_game FOREIGN KEY(league_game_id) REFERENCES league.league_game(id),
    CONSTRAINT fk_account FOREIGN KEY(account_id) REFERENCES league.account(id)
);
CREATE INDEX pick_account_value_ix ON league.pick(account_id, value);
CREATE INDEX pick_account_game_ix ON league.pick(account_id, league_game_id);
CREATE INDEX pick_game_ix ON league.pick(league_game_id);
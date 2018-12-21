create table price_day (
	price_id	bigserial,
	CONSTRAINT	price_PK_day PRIMARY KEY (price_id),
	symbol_id	serial not null,
	CONSTRAINT	price_FK_symbol_id FOREIGN KEY (symbol_id) REFERENCES symbol (symbol_id),
	day 		date not null,
	open		numeric(13,4),	-- account for FOREX
	high		numeric(13,4),
	low			numeric(13,4),
	close		numeric(13,4),
	volume		bigserial		-- account for Indicies and growth
);

CREATE UNIQUE INDEX price_day_IX_symbol_id ON price_day (symbol_id, day);
CREATE INDEX price_day_IX_day ON price_day (day, symbol_id);

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO apical_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO apical_user;
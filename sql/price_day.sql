create table price_day (
	price_id	bigserial,
	CONSTRAINT	price_PK_day PRIMARY KEY (price_id),
	symbol_id	serial not null,
	CONSTRAINT	price_FK_symbol_id FOREIGN KEY (symbol_id) REFERENCES symbol (symbol_id),
	day 		date not null,
	open		numeric(12,4),	-- account for FOREX
	high		numeric(12,4),
	low			numeric(12,4),
	close		numeric(12,4),
	volume		bigserial		-- account for Indicies and growth
);

CREATE UNIQUE INDEX price_day_IX_symbol_id ON price_day (symbol_id, day);
CREATE INDEX price_day_IX_day ON price_day (day, symbol_id);

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO apical_user;

create table symbol (
	symbol_id	serial,
	CONSTRAINT	symbol_PK PRIMARY KEY (symbol_id),
	symbol 		varchar(20) not null,
	exchange	varchar(20) not null,
	optionable	bit,
	y_symbol	varchar(20)
);

CREATE UNIQUE INDEX symbol_UQ_symbol_exchange on symbol (symbol, exchange);
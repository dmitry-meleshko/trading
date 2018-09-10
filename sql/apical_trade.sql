  create database apical_trade;

  create table apical_trade.Quotes (symbol varchar(16), date date, open real, high real, low real, close real, volume int, constraint symbol_date primary key (symbol, date));
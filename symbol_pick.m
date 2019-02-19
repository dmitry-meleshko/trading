function [ticker, exchange, sym_id, y_symbol] = symbol_pick()

OUT_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\quotes', getenv('Username'));
if (~exist(OUT_DIR, 'dir'))
    mkdir(OUT_DIR)
end;

conn = db_conn();

% TODO: figure out cursor focus
%handles.popup1.String = data{:, 1};
%selectedIndex = handles.popup1.Value; % A number
%A = T{selectedIndex, 2};
%B = T{selectedIndex, 3};
%handles.popup1 = get(handles.popup1, 'Value');

[ticker, exchange, sym_id, y_symbol] = ui_symbol_pick(conn);
if isempty(sym_id)
    error('Failed to pick a symbol.')
end

query = ['SELECT price_id, to_char("day", ''DD-Mon-YYYY'') as "day", '...
    '"open", high, low, "close", volume ' ...
    'FROM price_day pd ' ...
    'JOIN symbol s ON pd.symbol_id = s.symbol_id ' ...
    'WHERE s.symbol_id = ', sym_id, ...
    'ORDER BY pd.day'];

dr = fetch(conn, query);

% convert date formats
%dr(:, 2) = datestr(dr{:, 2}, 'dd-mmm-yyyy')

Quotes = cell2table(dr,  'VariableNames', ...
    {'PriceId' 'Date' 'Open' 'High' 'Low' 'Close' 'Volume'});

Quotes = extend_quotes_with_volatility(Quotes);

fname = fullfile(OUT_DIR, sprintf('%s_%s.mat', exchange, ticker));
fprintf('Saving %s file\n', fname);
save(fname, 'Quotes', '-v7.3');

close(conn)
end
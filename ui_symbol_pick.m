function [ticker, exchange, sym_id, y_symbol] = ui_symbol_pick(conn)
dropdown = '';
ticker = ''; exchange = ''; sym_id = ''; y_symbol = '';

dh = dialog('Position',[700 400 250 150],'Name','Select Symbol');
uicontrol('Parent',dh,...
    'Style','text',...
    'Position',[20 100 80 20],...
    'String','Enter Ticker: ', ...
    'HorizontalAlignment', 'left');

uicontrol('Parent', dh,...
    'Style', 'edit',...
    'Position', [100 100 100 24],...
    'HorizontalAlignment', 'left',...
    'Callback', @fetch_tickers);

%uicontrol(tbox_tick);

% Wait for d to close before running to completion
uiwait(dh);

    function fetch_tickers(source, ~)
        val = source.String;
        if ~isempty(val)
            % 'SELECT s.symbol_id, s.symbol, s.exchange, s.y_symbol ' ...
            query = ['SELECT symbol || '' | '' || exchange || '' | '' || '...
                ' symbol_id || '' | '' || y_symbol AS result '...
                'FROM symbol ' ...
                'WHERE y_symbol like ''', upper(val), '%'' '...
                'or symbol LIKE ''', upper(val), '%'' ' ...
                'ORDER BY symbol, y_symbol, exchange'];
            
            dr = select(conn, query);
            
            uicontrol('Parent',dh,...
                'Style','popupmenu',...
                'String', ['Select Symbol'; table2cell(dr)],...
                'Position',[20 60 180 25],...
                'Callback',@popup_callback);

            uicontrol('Parent',dh,...
                'Position',[89 20 70 25],...
                'String','Select',...
                'Callback','delete(gcf)');
            
        end
    end

    % Converts selected line into symbol values
    function popup_callback(popup, ~)
        idx = popup.Value;
        popup_items = popup.String;
        line = char(popup_items(idx,:));
        c = strsplit(line, ' | ');
        ticker = c{1};
        exchange = c{2};
        sym_id = c{3};
        y_symbol = c{4};
    end
end
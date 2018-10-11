function [] = r30_snapshot_view()
    % Snapshot view on day X for all tickers
    % last price
    % series volatility - 252 days?
    % high / low volatility
    % 10 day vol, 20 day vol, 90 day vol
    clc; clear; close all;

    IN_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\quotes', getenv('Username'));
    OUT_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\views', getenv('Username'));
    if (~exist(OUT_DIR, 'dir'))
        mkdir(OUT_DIR)
    end;
    SNAP_COLS = 33;    % number of columns in snapshot view
    
    optionsSymb = fetchOptionsTickers(OUT_DIR);

    Q_SRC = {'AMEX', 'NASDAQ', 'NYSE', 'FOREX', 'INDEX'};

    snapshot_cells = cell(0, SNAP_COLS);   % declare empty cell array to hold snapshot
    % take quotes data from MAT files and save in a map file
    for key = Q_SRC
        exchange = key{:};
        files = dir(fullfile(IN_DIR, sprintf('%s_*.mat', exchange)));
        fprintf('Loading tickers from %s\n', exchange);
        
        for i = 1:length(files)
            fname = fullfile(IN_DIR, files(i).name);
            if exist(fname, 'file') == 2    % 2 means file, not folder?
                [filepath,name,ext] = fileparts(fname);

                % valid filenames have EXCHANGE_TICKER.mat format
                split_on = strfind(name, '_');
                if isempty(split_on)
                    continue;
                end

                % hang on to ticker name
                split_on = int16(split_on);
                ticker = name(split_on+1:end);
                
                options = false;
                % is this a matching ticker with tradeable options?
                if (height(optionsSymb(strcmp(optionsSymb.Symbol, ticker), :)) > 0)
                    options = true;
                end

                %fprintf('Loading %s file for %s ticker from %s\n', name, ticker, exchange);
                load(fname);
                % grab last row, prepend ticker and exchange into new cell array
                last_row = table2cell(Quotes(end,:));
                last_row = {ticker, exchange, options, last_row{:}};
                snapshot_cells(end+1,:) = last_row;
            end
        end
    end

    % save cells into table
    col_names = Quotes.Properties.VariableNames;
    SummaryView = cell2table(snapshot_cells,  'VariableNames', {'Ticker' 'Exchange' 'Options' col_names{:}});
    % sort by Exchange, Date, Ticker
    SummaryView = sortrows(SummaryView, [4, 2, 1], {'descend' 'descend' 'ascend'} );

    fname = fullfile(OUT_DIR, 'SummaryView.mat');
    fprintf('Saving %s file\n', fname);
    save(fname, 'SummaryView', '-v7.3');    % .mat file
    fname = fullfile(OUT_DIR, 'SummaryView.csv');
    writetable(SummaryView, fname);

    % the end
end


function [optionsTickers] = fetchOptionsTickers(FILE_DIR)    
    webOpts = weboptions('Timeout', 30);
    cboeURL = 'http://www.cboe.com/publish/scheduledtask/mktdata/cboesymboldir2.csv';
    cboeFile = fullfile(FILE_DIR, 'cboesymboldir2.csv');
    try
        cboeFile = websave(cboeFile, cboeURL, webOpts);
    catch
        warning('Failed to fetch options symbol data from %s', cboeFile)
        % it's OK though, we probably have a local file from the last run
    end
    
    % import specs
    formatSpec = '%s%s%s%d%s%s%s%s%s%d%[^\n\r]';
    
    headers = {'Company','Symbol','DPM','Cycle','TradedC2', ...
            'LEAPS2019', 'LEAPS2020', 'LEAPS2021', 'ProductTypes', 'Station'};
    optionsTickers = import_quotes_csv(cboeFile, formatSpec, headers, 3, Inf);
    if height(optionsTickers) < 2
        % empty file -- failed to fetch symbols
        error('Missing options symbols data. We are done.');
    end
    
    optionsTickers = sortrows(optionsTickers, 2); % Symbol ascending
end
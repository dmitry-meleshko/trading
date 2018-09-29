% snapshot view on day X for all tickers
% last price
% series volatility - 252 days?
% high / low volatility
% 10 day vol, 20 day vol, 90 day vol
clc; clear all;

IN_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\quotes', getenv('Username'));
OUT_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\views', getenv('Username'));
if (~exist(OUT_DIR, 'dir'))
    mkdir(OUT_DIR)
end;

Q_SRC = {'AMEX', 'FOREX', 'INDEX', 'NASDAQ', 'NYSE'};
ANNUAL_DAYS = 252;  % that's how many *trading* days there are

snapshot_cells = cell(0, 24);   % declare empty cell array to hold snapshot
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
        
            %fprintf('Loading %s file for %s ticker from %s\n', name, ticker, exchange);
            load(fname);
            % grab last row, prepend ticker and exchange into new cell array
            last_row = table2cell(Quotes(end,:));
            last_row = {ticker, exchange, last_row{:}};
            snapshot_cells(end+1,:) = last_row;
        end
    end
end

% save cells into table
col_names = Quotes.Properties.VariableNames;
SummaryView = cell2table(snapshot_cells,  'VariableNames', {'Ticker' 'Exchange' col_names{:}});
% sort by Exchange, Date, Ticker
SummaryView = sortrows(SummaryView, [2, 3, 1], {'ascend' 'descend' 'ascend'} );

fname = fullfile(OUT_DIR, 'SummaryView.mat');
fprintf('Saving %s file\n', fname);
save(fname, 'SummaryView', '-v7.3');    % .mat file
fname = fullfile(OUT_DIR, 'SummaryView.csv');
writetable(SummaryView, fname);

% the end


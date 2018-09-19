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

%Date = input('Enter trading date: ' ,'s');
% Date = '';
% Ticker = ''; Exchange = '';
% Price = 0;
% VolYear = 0; VolHigh = 0; VolLow = 0;
% Vol10d = 0; Vol20d = 0; Vol90d = 0;


% holds summary view for all symbols
% SummaryView = table(Date, Ticker, Exchange, Price, VolYear, VolHigh, VolLow, ...
%     Vol10d, Vol20d, Vol90d);
%SummaryView = ModelAdvisor.Table(1, 7);
%SummaryView.Properties.VariableNames = {'Date', Ticker, Exchange, 'Price', 'VolYear', 'VolHigh', 'VolLow', 'Vol10d', 'Vol20d', 'Vol90d'};

snapshot_cells = cell(0, 24);   % declare empty cell array to hold snapshot
% take quotes data from MAT files and save in a map file
for key = Q_SRC
    exchange = key{:};
    files = dir(fullfile(IN_DIR, sprintf('%s_*.mat', exchange)));

    for i = 1:length(files)
        fname = fullfile(IN_DIR, files(i).name);
        if exist(fname, 'file') == 2
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
            % grab last row, prepend ticker and exchnge into new cell array
            last_row = table2cell(Quotes(end,:));
            last_row = {ticker, exchange, last_row{:}};
            snapshot_cells(end+1,:) = last_row;
            
            %QuotesMap(key{:}) = eval(key{:}); % yeah, eval is evil.
        end
    end
end

% save cells into table
col_names = Quotes.Properties.VariableNames;
SummaryView = cell2table(snapshot_cells,  'VariableNames', {'Ticker' 'Exchange' col_names{:}});

%  % load previously saved quotes from Exchange files
%  for k = Q_SRC
%      exchange = k{:};
%      if (~isKey(QuotesMap, exchange)); continue; end;
%      
%      QM = QuotesMap(exchange);
%      
%      tickers = unique(QM.Symbol);    % extract tickers
%      for i = 1:length(tickers)
%          T = tickers{i};
%          
%          % filter by ticker and extract date, prices and volume
%          Quotes = QM(strcmp(QM.Symbol, T), [2:7]);
%          
%          % use closing price (index 5) and 20 day window
%          [vol, std_log, std_price, std_change] = calc_volatility(Quotes{:,5}, 10, ANNUAL_DAYS);
%          Quotes.Vol10d = vol;
%          Quotes.StdLog10d = std_log;
%          Quotes.StdPrice10d = std_price;
%          Quotes.ChangeStd10d = std_change;
%          
%          [vol, std_log, std_price, std_change] = calc_volatility(Quotes{:,5}, 20, ANNUAL_DAYS);
%          Quotes.Vol20d = vol;
%          Quotes.StdLog20d = std_log;
%          Quotes.StdPrice20d = std_price;
%          Quotes.ChangeStd20d = std_change;
%          
%          [vol, std_log, std_price, std_change] = calc_volatility(Quotes{:,5}, 90, ANNUAL_DAYS);
%          Quotes.Vol90d = vol;
%          Quotes.StdLog90d = std_log;
%          Quotes.StdPrice90d = std_price;
%          Quotes.ChangeStd90d = std_change;
%          
%          [vol, std_log, std_price, std_change] = calc_volatility(Quotes{:,5}, ANNUAL_DAYS, ANNUAL_DAYS);
%          Quotes.VolYear = vol;
%          Quotes.StdLogYear = std_log;
%          Quotes.StdPriceYear = std_price;
%          Quotes.ChangeStdYear = std_change;
%          
%          %plot(Vol(21:end,2));
%          fname = fullfile(OUT_DIR, sprintf('%s_%s.mat', exchange, T));
%          fprintf('Saving %s file\n', fname);
%          save(fname, 'Quotes', '-v7.3');
%      end
%  end

  
%  FOO = [
%      47.58; 47.78 ; 48.09 ; 47.52; 48.47 ; 48.38; 49.30 ; 49.61 ; 50.03 ;
%      51.65 ; 51.65 ; 51.57; 50.60; 50.45; 50.83 ; 51.08 ; 51.26 ; 50.89;
%      50.51; 51.42 ; 52.09 ; 55.83 ; 55.79; 56.20
%      ];
%  
%  [vol, std_log, std_price, std_change] = calc_volatility(FOO, 20, 252);
%  plot(FOO(21:end,2));
% Step 2 - split EODData quotes_EXHCNAGE.mat files into individual tickers
clc; clear all;

IN_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData', getenv('Username'));
OUT_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\quotes', getenv('Username'));
if (~exist(OUT_DIR, 'dir'))
    mkdir(OUT_DIR)
end;

Q_SRC = {'AMEX', 'FOREX', 'INDEX', 'NASDAQ', 'NYSE'};

% load previously saved quotes
QuotesMap = containers.Map();
load_quotes(QuotesMap, IN_DIR, Q_SRC);

 % load previously saved quotes from Exchange files
 for k = Q_SRC
     exchange = k{:};
     if (~isKey(QuotesMap, exchange)); continue; end;
     
     QM = QuotesMap(exchange);
     
     tickers = unique(QM.Symbol);    % extract tickers
     for i = 1:length(tickers)
         T = tickers{i};
         
         % filter by ticker and extract date, prices and volume
         Quotes = QM(strcmp(QM.Symbol, T), [2:7]);
         
         Quotes = extend_quotes_with_volatility(Quotes);

         fname = fullfile(OUT_DIR, sprintf('%s_%s.mat', exchange, T));
         fprintf('Saving %s file\n', fname);
         save(fname, 'Quotes', '-v7.3');
     end
 end


function [] = load_quotes(QuotesMap, Q_DIR, Q_SRC)
    % take quotes data from MAT files and save in a map file
    for key = Q_SRC
        fname = fullfile(Q_DIR, sprintf('quotes_%s.mat', key{:}));
        if exist(fname, 'file') == 2
            fprintf('Loading %s file\n', fname); 
            load(fname);
            QuotesMap(key{:}) = eval(key{:}); % yeah, eval is evil.
        end
    end
end
% main

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
         
         % use closing price (index 5) and 20 day window
         Vol = calc_volatility(Quotes{:,5}, 20);
         Quotes.Vol20d = Vol;
         
         %plot(Vol(21:end,2));
         fname = fullfile(OUT_DIR, sprintf('%s_%s.mat', exchange, T));
         fprintf('Saving %s file\n', fname);
         save(fname, 'Quotes', '-v7.3');
     end
 end


% FOO = [
%     71.75; 71.46; 70.99; 68.49; 69.10; 69.61; 67.72; 65.48; 66.31; 65.66;
%     63.93; 63.19; 65.68; 67.32; 66.23; 64.31; 64.66; 63.99; 61.81; 61.67;
%     60.16; 59.96; 59.51; 58.71; 62.33; 62.75; 62.72; 62.65; 61.17; 67.21
% ];
% 
% FOO = calc_volatility(FOO, 20);
% plot(FOO(21:end,2));   
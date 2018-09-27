% main

IN_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData', getenv('Username'));
OUT_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\quotes', getenv('Username'));
if (~exist(OUT_DIR, 'dir'))
    mkdir(OUT_DIR)
end;

Q_SRC = {'AMEX', 'FOREX', 'INDEX', 'NASDAQ', 'NYSE'};
ANNUAL_DAYS = 252;  % that's how many *trading* days there are

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
         [vol, std_log, std_price, std_change] = calc_volatility(Quotes{:,5}, 10, ANNUAL_DAYS);
         Quotes.SigmaYear10d = vol;
         Quotes.SigmaDay10d = std_log;
         Quotes.SigmaDayInBase10d = std_price;
         Quotes.SigmaLastPrice10d = std_change;
         
         [vol, std_log, std_price, std_change] = calc_volatility(Quotes{:,5}, 20, ANNUAL_DAYS);
         Quotes.SigmaYear20d = vol;
         Quotes.SigmaDay20d = std_log;
         Quotes.SigmaDayInBase20d = std_price;
         Quotes.SigmaLastPrice20d = std_change;
         
         [vol, std_log, std_price, std_change] = calc_volatility(Quotes{:,5}, 90, ANNUAL_DAYS);
         Quotes.SigmaYear90d = vol;
         Quotes.SigmaDay90d = std_log;
         Quotes.SigmaDayInBase90d = std_price;
         Quotes.SigmaLastPrice90d = std_change;
         
         [vol, std_log, std_price, std_change] = calc_volatility(Quotes{:,5}, ANNUAL_DAYS, ANNUAL_DAYS);
         Quotes.SigmaYear = vol;
         Quotes.SigmaDayYear = std_log; % TODO: is this necessary?
         Quotes.SigmaDayInBaseYear = std_price;
         Quotes.SigmaLastPriceYear = std_change;
         
         %plot(Vol(21:end,2));
         fname = fullfile(OUT_DIR, sprintf('%s_%s.mat', exchange, T));
         fprintf('Saving %s file\n', fname);
         save(fname, 'Quotes', '-v7.3');
     end
 end

  
%  FOO = [
%      47.58; 47.78 ; 48.09 ; 47.52; 48.47 ; 48.38; 49.30 ; 49.61 ; 50.03 ;
%      51.65 ; 51.65 ; 51.57; 50.60; 50.45; 50.83 ; 51.08 ; 51.26 ; 50.89;
%      50.51; 51.42 ; 52.09 ; 55.83 ; 55.79; 56.20
%      ];
%  
%  [vol, std_log, std_price, std_change] = calc_volatility(FOO, 20, 252);
%  plot(FOO(21:end,2));
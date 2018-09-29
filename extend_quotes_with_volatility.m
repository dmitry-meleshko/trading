function Quotes = extend_quotes_with_volatility(Quotes)
    % Takes Quotes map from eod_quotes2tickers and expands daily data
    % by adding volatility for 10 day, 20 day, 90 day and annual windows.
    
    ANNUAL_DAYS = 252;  % that's how many *trading* days there are
    
    % for short timelines return 0s and move on. Avoids size mismatch error
    row_count = height(Quotes);
    if row_count < 10
        % match the number of rows before assigning 0s
        Quotes.SigmaYear10d = zeros(height(Quotes), 1);
        Quotes.SigmaDay10d = zeros(height(Quotes), 1);
        Quotes.SigmaDayInBase10d = zeros(height(Quotes), 1);
        Quotes.SigmaLastPrice10d = zeros(height(Quotes), 1);
        
        Quotes.SigmaYear20d = zeros(height(Quotes), 1);
        Quotes.SigmaDay20d = zeros(height(Quotes), 1);
        Quotes.SigmaDayInBase20d = zeros(height(Quotes), 1);
        Quotes.SigmaLastPrice20d = zeros(height(Quotes), 1);
        
        Quotes.SigmaYear90d = zeros(height(Quotes), 1);
        Quotes.SigmaDay90d = zeros(height(Quotes), 1);
        Quotes.SigmaDayInBase90d = zeros(height(Quotes), 1);
        Quotes.SigmaLastPrice90d = zeros(height(Quotes), 1);
        
        Quotes.SigmaYear = zeros(height(Quotes), 1);
        Quotes.SigmaDayYear = zeros(height(Quotes), 1);
        Quotes.SigmaDayInBaseYear = zeros(height(Quotes), 1);
        Quotes.SigmaLastPriceYear = zeros(height(Quotes), 1);
        
        return;
    end

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
end


%  FOO = [
%      47.58; 47.78 ; 48.09 ; 47.52; 48.47 ; 48.38; 49.30 ; 49.61 ; 50.03 ;
%      51.65 ; 51.65 ; 51.57; 50.60; 50.45; 50.83 ; 51.08 ; 51.26 ; 50.89;
%      50.51; 51.42 ; 52.09 ; 55.83 ; 55.79; 56.20
%      ];
%  
%  [vol, std_log, std_price, std_change] = calc_volatility(FOO, 20, 252);
%  plot(FOO(21:end,2));

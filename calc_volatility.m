% Helper function. Called from:
%   extend_quotes_with_volatility.m
function [sigma_year, sigma_daily, sigma_daily_in_base, sigma_of_last_price] = calc_volatility(Series, window, periods, startIndex)
    if nargin<=4
        startIndex = 1;
    end
    
    sigma_year = zeros(length(Series), 1); % series volatility for the window
    sigma_daily = zeros(length(Series), 1); % standard deviation of log price
    sigma_daily_in_base = zeros(length(Series), 1); % standard deviation in base currency (USD)
    % most recent price change expressed in STDEV of the previous window
    sigma_of_last_price = [];

    % convert series to natural log and diff each number with a previous entry
    for i = startIndex:length(Series)-window
        % get a window sized chunk of prices
        chunk = Series(i:window+i);
        % return = ln(Price2 / Price1) = ln(Price2) - ln(Price1)
        log_change = diff(log(chunk));  % vectorized substraction
        %mean_change = mean(log_change);
        sigma_of_log_change = std(log_change);
        % annualize volatility and save at the end of the window
        sigma_year(i+window) = sigma_of_log_change * sqrt(periods);
        sigma_daily(i+window) = sigma_of_log_change;
        % last price * STDEV for the window = price change in STDEV
        sigma_daily_in_base(i+window) = chunk(window+1) * sigma_of_log_change;
    end
    
    % look back at the preceding window, take last STDEV expressed in $
    % and use it to divide current price change = current spike in STDEV
    price_diff = diff(Series);
    prev_std_price = sigma_daily_in_base(2:end);  % drop 1st empty value or alignment
    prev_std_price = prev_std_price(1:end-1);   % shifted to previous row
    sigma_of_last_price = price_diff(2:end) ./ prev_std_price;
    sigma_of_last_price(~isfinite(sigma_of_last_price)) = 0;  % clean up after division by 0
    sigma_of_last_price = [0; 0; sigma_of_last_price]; % extra elements to match other data
end
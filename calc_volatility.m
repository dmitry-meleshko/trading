function [vol, std_log, std_price, std_change] = calc_volatility(Series, window, periods)

    vol = zeros(length(Series), 1); % series volatility for the window
    std_log = zeros(length(Series), 1); % standard deviation of log price
    std_price = zeros(length(Series), 1); % standard deviation in $
    % most recent price change expressed in STDEV of the previous window
    std_change = [];

    % convert series to natural log and diff each number with a previous entry
    for i = 1:length(Series)-window
        % get a window sized chunk of prices
        chunk = Series(i:window+i);
        % return = ln(Price2 / Price1) = ln(Price2) - ln(Price1)
        log_change = diff(log(chunk));  % vectorized substraction
        %mean_change = mean(log_change);
        std_change = std(log_change);
        vol_annual = std_change * sqrt(periods);    % annualize volatility
        % save volatility & standard deviations at the end of the window
        vol(i+window) = vol_annual;
        std_log(i+window) = std_change;
        % last price * STDEV for the window = price change in STDEV
        std_price(i+window) = chunk(window+1) * std_change;
    end
    
    % look back at the preceding window, take last STDEV expressed in $
    % and use it to divide current price change = current spike in STDEV
    price_diff = diff(Series);
    prev_std_price = std_price(2:end);  % drop 1st empty value or alignment
    prev_std_price = prev_std_price(1:end-1);   % shifted to previous row
    std_change = price_diff(2:end) ./ prev_std_price;
    std_change(~isfinite(std_change)) = 0;  % clean up after division by 0
    std_change = [0; 0; std_change]; % extra elements to match other data
end
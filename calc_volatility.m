function [Series] = calc_volatility(Series, window)
    % add column for volatility
    Series = [Series zeros(length(Series), 1)];

    % convert series to natural log and diff each number with a previous entry
    ANNUAL_DAYS = 252;  % that's ho many *trading* days there are

    for i = 1:length(Series)-window
        % get a window sized chunk of prices
        chunk = Series(i:window+i, 1);
        % return = ln(Price2 / Price1) = ln(Price2) - ln(Price1)
        log_change = diff(log(chunk));
        %mean_change = mean(log_change);
        std_change = std(log_change);
        vol_annual = std_change * sqrt(ANNUAL_DAYS);    % annualize volatility
        % assign volatility to the end of the sliding window
        Series(i+window, 2) = vol_annual;
    end
end
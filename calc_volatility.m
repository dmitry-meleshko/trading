function [Vol] = calc_volatility(Series, window, periods)
    % add column for volatility
    %Series = [Series zeros(length(Series), 1)];
    Vol = zeros(length(Series), 1);

    % convert series to natural log and diff each number with a previous entry
    for i = 1:length(Series)-window
        % get a window sized chunk of prices
        chunk = Series(i:window+i);
        % return = ln(Price2 / Price1) = ln(Price2) - ln(Price1)
        log_change = diff(log(chunk));
        %mean_change = mean(log_change);
        std_change = std(log_change);
        vol_annual = std_change * sqrt(periods);    % annualize volatility
        % assign volatility to the end of the sliding window
        Vol(i+window) = vol_annual;
    end
end
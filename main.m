% main

QuotesMap = containers.Map();
load_quotes(QuotesMap);

AMEX = QuotesMap('AMEX');
tickers = unique(AMEX.Symbol);    % extract tickers
for t = tickers
    % use closing price and 20 day window
    AMEX_VOL = calc_volatility(AMEX{:,6}, 20);  
    %plot(AMEX_VOL(21:end,2));
end



% FOO = [
%     71.75; 71.46; 70.99; 68.49; 69.10; 69.61; 67.72; 65.48; 66.31; 65.66; 63.93; 63.19; 65.68; 67.32; 66.23; 64.31; 64.66; 63.99; 61.81; 61.67; 60.16; 59.96; 59.51; 58.71; 62.33; 62.75; 62.72; 62.65; 61.17; 67.21
% ];
% 
% FOO = calc_volatility(FOO, 20);
% plot(FOO(21:end,2));   
%%
clear all; clc;

[ticker, exchange, sym_id, y_symbol] = symbol_pick();
%ticker =  'BA';
%exchange = 'NYSE';
days = 252 * 100; % how many days to load

IN_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\quotes', getenv('Username'));
Q_SRC = {'NYSE', 'NASDAQ', 'AMEX', 'FOREX'};

% load ticker from one of the exchange files
for k = Q_SRC
    exchange = k{:};
    fname = fullfile(IN_DIR, sprintf('%s_%s.mat', exchange, ticker));
    try
        load(fname)
    catch
        continue
    end
    break;        
end

%% Charting
Series = Quotes(1:end, :);
if height(Quotes) > days
    Series = Quotes(end-days:end, :);
end

%date = datetime(Series.Date);  % incompatible with bar()?
%dateNum = datenum(Series.Time);
plotTitle = sprintf('%s (%s)', ticker, exchange);

%%

%figure('units','normalized','outerposition',[0 0 1 1])
figH = figure('Name', plotTitle, 'NumberTitle', 'off');
figH.Position = [20, 40, 1500, 740];

%s(1) = subplot(5, 1, 1);
subplot('Position', [0.04 0.8 0.96 0.2]);
%plot(date, Quotes.Close)
%p = plot(dateNum, Series.Close);
%candle(Series, 'b');
candle(Series, 'b');
p.XDataSource = 'Series.Time';   % for future data updates
p.YDataSource = 'Series.Close';   
title(plotTitle);
datetick('x', 'yyyy-mm-dd', 'keeplimits', 'keepticks')
axis 'tight'
axsH = gca;
set(gca,'Xticklabel',[])
%axsH.XTickLabelRotation = 45;   % angle dates to fit
ylabel('Price, $')
grid on

% Add moving averages
ema20 = movavg(Series.Close, 'exponential', 20);
ema50 = movavg(Series.Close, 'exponential', 50);
ema100 = movavg(Series.Close, 'exponential', 100);
hold on
plot(Series.Time,ema20,'r');
plot(Series.Time,ema50,'g');
plot(Series.Time,ema100,'c');
hold off
legend('Price', '20-Day EMA','50-Day EMA', '100-Day EMA')

%s(2) = subplot(5, 1, 2);
subplot('Position', [0.04 0.6 0.96 0.2]);

%bar(Quotes.SigmaLastPrice20d(end-252:end))
p = bar(Series.Time, Series.SigmaLastPrice20d);
%p = plot(dateNum, Series.SigmaLastPrice20d);
p.XDataSource = 'Series.Time';
p.YDataSource = 'Series.SigmaLastPrice20d';     
legend('20 day price');
datetick('x', 'yyyy-mm-dd','keeplimits', 'keepticks')
axis 'tight'
axsH = gca;
%axsH.XTickLabelRotation = 45;
ylabel('Volatility, \sigma')
grid on


%s(3) = subplot(5, 1, 3);
subplot('Position', [0.04 0.4 0.96 0.15]);
hold on
p = plot(Series.Time, Series.SigmaYear20d, 'r');
p.XDataSource = 'Series.Time';
p.YDataSource = 'Series.SigmaYear20d'; 
p = plot(Series.Time, Series.SigmaYear90d, 'k');
p.XDataSource = 'Series.Time';
p.YDataSource = 'Series.SigmaYear90d';
p = plot(Series.Time, Series.SigmaYear, 'b');
p.XDataSource = 'Series.Time';
p.YDataSource = 'Series.SigmaYear';
legend('20 day', '90 day', 'Year');
%title('20 day')
%datetick('x', 'yyyy-mm-dd','keeplimits', 'keepticks')
axis 'tight'
axsH = gca;
set(gca,'Xticklabel',[])
%axsH.XTickLabelRotation = 45;
ylabel('Volatility, \sigma')
grid on


%s(4) = subplot(5, 1, 4);
subplot('Position', [0.04 0.25 0.96 0.15]);
hold on
p = plot(Series.Time, Series.Skewness20d, 'r');
p.XDataSource = 'Series.Time';
p.YDataSource = 'Series.Skewness20d';   
p = plot(Series.Time, Series.Skewness90d, 'k');
p.XDataSource = 'Series.Time';
p.YDataSource = 'Series.Skewness90d';
p = plot(Series.Time, Series.SkewnessYear, 'b');
p.XDataSource = 'Series.Time';
p.YDataSource = 'Series.SkewnessYear';
legend('20 day', '90 day', 'Year');
%title('20 day')
%datetick('x', 'yyyy-mm-dd','keeplimits', 'keepticks')
axis 'tight'
axsH = gca;
set(gca,'Xticklabel',[])
%axsH.XTickLabelRotation = 45;
ylabel('Skewness, \gamma_{1}')
grid on

%s(5) = subplot(5, 1, 5);
subplot('Position', [0.04 0.1 0.96 0.15]);
hold on
p = plot(Series.Time, Series.Kurtosis20d, 'r');
p.XDataSource = 'Series.Time';
p.YDataSource = 'Series.Kurtosis20d';   
p = plot(Series.Time, Series.Kurtosis90d, 'k');
p.XDataSource = 'Series.Time';
p.YDataSource = 'Series.Kurtosis90d';
p = plot(Series.Time, Series.KurtosisYear, 'b');
p.XDataSource = 'Series.Time';
p.YDataSource = 'Series.KurtosisYear';
legend('20 day', '90 day', 'Year');
%title('20 day')
datetick('x', 'yyyy-mm-dd','keeplimits', 'keepticks')
axis 'tight'
axsH = gca;
%axsH.XTickLabelRotation = 45;
ylabel('Kurtosis, \gamma_{2}')
grid on

%pause 

%% Update plots
refreshdata
drawnow

    
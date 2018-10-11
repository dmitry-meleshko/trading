%%
clear all; clc;

ticker =  'FDS';
days = 252  * 2; % how many days to load

IN_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\quotes', getenv('Username'));
Q_SRC = {'NYSE', 'NASDAQ', 'AMEX'};

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

Series = Quotes(end-days:end, :);

%date = datetime(Series.Date);  % incompatible with bar()?
dateNum = datenum(Series.Date);
plotTitle = sprintf('%s (%s)', ticker, exchange);

%figure('units','normalized','outerposition',[0 0 1 1])
figH = figure('Name', plotTitle , 'NumberTitle', 'off');
figH.Position = [1000, 50, 1500, 1300];

s(1) = subplot(5, 1, 1);
%plot(date, Quotes.Close)
p = plot(dateNum, Series.Close);
p.XDataSource = 'dateNum';   % for future data updates
p.YDataSource = 'Series.Close';   
title(plotTitle);
datetick('x', 'yyyy-mm-dd','keeplimits', 'keepticks')
axis 'tight'
axsH = gca;
axsH.XTickLabelRotation = 45;   % angle dates to fit
ylabel('Price, $')
grid on

s(2) = subplot(5, 1, 2);
%bar(Quotes.SigmaLastPrice20d(end-252:end))
p = bar(dateNum, Series.SigmaLastPrice20d);
p.XDataSource = 'dateNum';
p.YDataSource = 'Series.SigmaLastPrice20d';   
legend('20 day price');
datetick('x', 'yyyy-mm-dd','keeplimits', 'keepticks')
axis 'tight'
axsH = gca;
axsH.XTickLabelRotation = 45;
ylabel('Volatility, \sigma')
grid on


s(3) = subplot(5, 1, 3);
hold on
p = plot(dateNum, Series.SigmaYear20d, 'r');
p.XDataSource = 'dateNum';
p.YDataSource = 'Series.SigmaYear20d';   
p = plot(dateNum, Series.SigmaYear90d, 'k');
p.XDataSource = 'dateNum';
p.YDataSource = 'Series.SigmaYear90d';
p = plot(dateNum, Series.SigmaYear, 'b');
p.XDataSource = 'dateNum';
p.YDataSource = 'Series.SigmaYear';
legend('20 day', '90 day', 'Year');
%title('20 day')
datetick('x', 'yyyy-mm-dd','keeplimits', 'keepticks')
axis 'tight'
axsH = gca;
axsH.XTickLabelRotation = 45;
ylabel('Volatility, \sigma')
grid on

s(4) = subplot(5, 1, 4);
hold on
p = plot(dateNum, Series.Skewness20d, 'r');
p.XDataSource = 'dateNum';
p.YDataSource = 'Series.Skewness20d';   
p = plot(dateNum, Series.Skewness90d, 'k');
p.XDataSource = 'dateNum';
p.YDataSource = 'Series.Skewness90d';
p = plot(dateNum, Series.SkewnessYear, 'b');
p.XDataSource = 'dateNum';
p.YDataSource = 'Series.SkewnessYear';
legend('20 day', '90 day', 'Year');
%title('20 day')
datetick('x', 'yyyy-mm-dd','keeplimits', 'keepticks')
axis 'tight'
axsH = gca;
axsH.XTickLabelRotation = 45;
ylabel('Skewness, \gamma_{1}')
grid on

s(5) = subplot(5, 1, 5);
hold on
p = plot(dateNum, Series.Kurtosis20d, 'r');
p.XDataSource = 'dateNum';
p.YDataSource = 'Series.Kurtosis20d';   
p = plot(dateNum, Series.Kurtosis90d, 'k');
p.XDataSource = 'dateNum';
p.YDataSource = 'Series.Kurtosis90d';
p = plot(dateNum, Series.KurtosisYear, 'b');
p.XDataSource = 'dateNum';
p.YDataSource = 'Series.KurtosisYear';
legend('20 day', '90 day', 'Year');
%title('20 day')
datetick('x', 'yyyy-mm-dd','keeplimits', 'keepticks')
axis 'tight'
axsH = gca;
axsH.XTickLabelRotation = 45;
ylabel('Kurtosis, \gamma_{2}')
grid on

%pause 

%% Update plots
refreshdata
drawnow

    
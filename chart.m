%%
clear all; clc;

ticker =  'MSFT';
days = 252  * 15; % how many days to load

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

s(1) = subplot(3, 1, 1);
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

s(2) = subplot(3, 1, 2);
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


s(3) = subplot(3, 1, 3);
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
%pause 

%% Update plots
refreshdata
drawnow

    
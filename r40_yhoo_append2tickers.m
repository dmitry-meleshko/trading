function [] = r40_yhoo_append2tickers()
    % Step 4 - append Y! history to EODData tickers in quotes\Exchange_Ticker.mat files
    % Continue to Step 3 to update Snapshot views with new data
    clc; clear; close all;

    IN_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\quotes\\yhoo', getenv('Username'));
    OUT_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData\\quotes', getenv('Username'));
    if (~exist(OUT_DIR, 'dir'))
        mkdir(OUT_DIR)
    end;
    
    ANNUAL_DAYS = 252;  % that's how many *trading* days there are

    %Q_SRC = {'AMEX', 'FOREX', 'INDEX', 'NASDAQ', 'NYSE'};
    Q_SRC = {'AMEX', 'NASDAQ', 'NYSE'};

    % import specs
    % Format string for each line of text:
    %	column1: datetimes (%{dd-MMM-yyyy}D)
    %   column2: double (%f)
    %	column3: double (%f)
    %   column4: double (%f)
    %	column5: double (%f)
    %   column6: double (%f)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%{dd-MMM-yyyy}D%f%f%f%f%f%[^\n\r]';
    headers = {'Date','Open','High','Low','Close','Volume'};

    % load previously saved quotes from Exchange files
    for k = Q_SRC
        exchange = k{:};

        files = dir(fullfile(IN_DIR, sprintf('%s_*.csv', exchange)));
        fprintf('Loading Y! tickers for %s\n', exchange);

        for i = 1:length(files)
            fname_Y = fullfile(IN_DIR, files(i).name);
            [filepath,name,ext] = fileparts(fname_Y);

            % valid filenames have EXCHANGE_TICKER.csv format
            split_on = strfind(name, '_');
            if isempty(split_on)
                continue;
            end

            % hang on to ticker name
            split_on = int16(split_on);
            ticker = name(split_on+1:end);

            %fprintf('Loading %s file for %s ticker from %s\n', name, ticker, exchange);
            Quotes_Y = import_quotes_csv(fname_Y, formatSpec, headers);
            if height(Quotes_Y) < 2
                % empty file -- failed to fetch quotes
                fname_ERR = fullfile(IN_DIR, sprintf('err_%s_%s.csv', exchange, ticker));
                fprintf('Missing data. Saving error in %s file\n', fname_ERR);
                movefile(fname_Y, fname_ERR)
                continue;
            end
            Quotes_Y = sortrows(Quotes_Y, 1); % Date ascending

            % load quotes for the same ticker from older sources
            Quotes = [];
            fname_MAT = fullfile(OUT_DIR, sprintf('%s_%s.mat', exchange, ticker));
            if exist(fname_MAT, 'file') == 2
                load(fname_MAT);
                % glue two datasets using last date from Y snapshot
                last_date = Quotes_Y.Date(1,:);
                last_row = Quotes(Quotes.Date == last_date,[1:6]);

                isSamePrice = true;
                for k = [2:5]   
                   if floor(last_row{:,k}) ~= floor(Quotes_Y{1,k})
                       % big problem: dates matched, but not prices
                       % assume the tickers/exchange is a wrong one
                       isSamePrice = false;
                        % preserve the data but don't merge
                        fname_ERR = fullfile(IN_DIR, sprintf('err_%s_%s.csv', exchange, ticker));
                        fprintf('Mismatched data %d and %d. Saving error in %s file\n', ...
                                    floor(last_row{:,k}), floor(Quotes_Y{1,k}), fname_ERR);
                        movefile(fname_Y, fname_ERR)
                       break;
                   end
                end

                if ~isSamePrice
                    continue;   % on to the next ticker file
                end

                % fake calculation - just grows the table to matchsize
                Quotes_Y = extend_quotes_with_volatility(Quotes_Y);
                Quotes = [Quotes; Quotes_Y(2:end,:)];
            else
                % there is no file with old data
                Quotes = Quotes_Y;
            end

            
            % recalculate vol, but a most since last year
            startIndex = height(Quotes) - ANNUAL_DAYS;
            if startIndex < 1
                startIndex = 1;
            end
            Quotes = extend_quotes_with_volatility(Quotes, startIndex);

            fname = fullfile(OUT_DIR, sprintf('%s_%s.mat', exchange, ticker));
            fprintf('Saving %s file\n', fname);
            %save(fname, 'Quotes', '-v7.3');
            
            % clean up processed file
            delete(fname_Y);
        end
    end
end

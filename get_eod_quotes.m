function [] = get_eod_quotes()
    % loads CSV files and saves them in binary .mat workspace
    
    % future home of quotes data
    AMEX = []; FOREX = []; INDEX = []; NASDAQ = []; NYSE = [];
    
    % load previously saved quotes
    Q_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData', getenv('Username'));
    Q_SRC = {'AMEX', 'FOREX', 'INDEX', 'NASDAQ', 'NYSE'};
    for key = Q_SRC
        fname = fullfile(Q_DIR, sprintf('quotes_%s.mat', key{:}));
        if exist(fname, 'file') == 2
            fprintf('Loading %s file\n', fname); 
            load(fname);
        end
    end
    
    % load quotes data from ZIP files
    QuotesMap = containers.Map();
    unzip_archives(QuotesMap);  
    for k = keys(QuotesMap)
        exchange = k{1};
        fprintf('Sorting %s source\n', exchange);
        % combine data from container with an existing variable
        % Yes, eval is evil. Live with it.
        quotes = [eval(exchange); QuotesMap(exchange)];
        quotes = unique(quotes);
        QuotesMap(exchange) = sortrows(quotes, [1, 2]);
    end

    save_quotes(QuotesMap, Q_DIR, Q_SRC);
end


function [] = save_quotes(QuotesMap, Q_DIR, Q_SRC) 
   for key = Q_SRC
        exchange = key{:};
        if isKey(QuotesMap, exchange)
            fname = fullfile(Q_DIR, sprintf('quotes_%s.mat', exchange));
            fprintf('Saving %s\n', fname);
            switch exchange
                case 'AMEX'
                    AMEX = QuotesMap(exchange);
                    save(fname, 'AMEX', '-v7.3');   
                case 'FOREX'
                    FOREX = QuotesMap(exchange);
                    save(fname, 'FOREX', '-v7.3');
                case 'INDEX'
                    INDEX = QuotesMap(exchange);
                    save(fname, 'INDEX', '-v7.3');
                case 'NASDAQ'
                    NASDAQ = QuotesMap(exchange);
                    save(fname, 'NASDAQ', '-v7.3');
                case 'NYSE'
                    NYSE = QuotesMap(exchange);
                    save(fname, 'NYSE', '-v7.3');
                otherwise
                    error('Unknown Exchange name. Failed to save data.')
            end
        end
    end 
end
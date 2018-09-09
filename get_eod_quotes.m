function [] = get_eod_quotes()
    % loads CSV files and saves them in binary .mat workspace
    
    % future home of quotes data
    Q_AMEX = []; Q_FOREX = []; Q_INDEX = []; Q_NASDAQ = []; Q_NYSE = [];
    
    % load previously saved quotes
    Q_DIR = 'C:\Users\206522262\Desktop\EODData\';
    Q_SRC = ['AMEX', 'FOREX', 'INDEX', 'NASDAQ', 'NYSE'];
    for f = Q_SRC
        fname = fullfile(Q_DIR, sprintf('quotes_%s.mat', f));
        if exist(fname, 'file') == 2
            load(fname);
        end
    end
    
    % load quotes data from ZIP files
    unzip_archives(QuotesMap);  
    for k = keys(QuotesMap)
        quotes = QuotesMap(k{1});
        quotes = unique(quotes);
        QuotesMap(k{1}) = sortrows(quotes, [1, 2]);
    end

    for f = Q_SRC
        
        save(FILE_QUOTES, 'QuotesMap', '-v7.3');
        if exist(fullfile(Q_DIR, Q_FILES), 'file') == 2
            load(fullfile(Q_DIR, Q_FILES));
        end
    end
    
end
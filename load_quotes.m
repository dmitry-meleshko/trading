function [] = load_quotes(QuotesMap)   
    % future home of quotes data
    %global AMEX FOREX INDEX NASDAQ NYSE;
    AMEX = []; FOREX = []; INDEX = []; NASDAQ = []; NYSE = [];
    
    % load previously saved quotes
    Q_DIR = sprintf('C:\\Users\\%s\\Desktop\\EODData', getenv('Username'));
    Q_SRC = {'AMEX', 'FOREX', 'INDEX', 'NASDAQ', 'NYSE'};
    %Q_SRC = {'FOREX'};

    for key = Q_SRC
        fname = fullfile(Q_DIR, sprintf('quotes_%s.mat', key{:}));
        if exist(fname, 'file') == 2
            fprintf('Loading %s file\n', fname); 
            load(fname);
            QuotesMap(key{:}) = eval(key{:}); % yeah, eval is evil.
        end
    end
end
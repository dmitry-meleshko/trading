% Helper function. Called from eod_quotes2tickers.m
function [] = load_quotes(QuotesMap, Q_DIR, Q_SRC)
    % take quotes data from MAT files and save in a map file
    for key = Q_SRC
        fname = fullfile(Q_DIR, sprintf('quotes_%s.mat', key{:}));
        if exist(fname, 'file') == 2
            fprintf('Loading %s file\n', fname); 
            load(fname);
            QuotesMap(key{:}) = eval(key{:}); % yeah, eval is evil.
        end
    end
end
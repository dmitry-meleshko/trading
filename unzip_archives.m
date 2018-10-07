% Helper function. Called from get_eod_quotes.m
function [] = unzip_archives(QuotesMap)
    % unzip EODData files for CSV importation
    
    in_dir = sprintf('C:\\Users\\%s\\Desktop\\EODData', getenv('Username'));
    % directory for processed files
    out_dir = sprintf('C:\\Users\\%s\\Desktop\\EODData\\processed', getenv('Username'));
    % temp dir used to unzip archives
    tmp_dir = sprintf('C:\\Users\\%s\\Desktop\\EODData\\tmp', getenv('Username'));

    if (~exist(out_dir, 'dir'))
        mkdir(out_dir)
    end;
    
    % import specs
    % Format string for each line of text:
    %   column1: text (%s)
    %	column2: datetimes (%{dd-MMM-yyyy}D)
    %   column3: double (%f)
    %	column4: double (%f)
    %   column5: double (%f)
    %	column6: double (%f)
    %   column7: double (%f)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%s%{dd-MMM-yyyy}D%f%f%f%f%f%[^\n\r]';
    headers = {'Symbol','Date','Open','High','Low','Close','Volume'};
    
    % wipe out data from previous run
    recreate_dir(tmp_dir);
    zip = dir(fullfile(in_dir, '*.zip'));
    for i = 1:length(zip)
        zip_file = zip(i).name;
        
        % valid filenames have EXCHANGE_YEAR.zip format
        split_on = strfind(zip_file, '_');
        if isempty(split_on)
            continue;
        end
        % hang on to Exchange name
        split_on = int16(split_on);
        exchange = zip_file(1:split_on-1);

        % extract CSV files and process
        unzip(fullfile(in_dir, zip_file), tmp_dir);
        csv = dir(fullfile(tmp_dir, '*.csv'));
        quotes = [];
        
        for i = 1:length(csv)
            temp = import_quotes_csv(fullfile(tmp_dir, csv(i).name), formatSpec, headers);
            quotes = [quotes; temp];
        end
        
        % uppend new quotes to previously preserved
        if isKey(QuotesMap, exchange) 
            quotes = [QuotesMap(exchange); quotes];
        end
        QuotesMap(exchange) = quotes;
        
        % move processed ZIP file
        movefile(fullfile(in_dir, zip_file), fullfile(out_dir, zip_file));
        recreate_dir(tmp_dir);  % post processing cleanup
    end
end


function [] = recreate_dir(dir)
    % wipe out directory and create it again
    if (exist(dir, 'dir'))
        rmdir(dir, 's');
    end;
    mkdir(dir);
end
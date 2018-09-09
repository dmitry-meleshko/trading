function [] = unzip_archives()
    % unzip files for CSV importation
    
    in_dir = 'C:\Users\206522262\Desktop\EODData';
    % directory for processed files
    out_dir = 'C:\Users\206522262\Desktop\EODData\processed';
    % temp dir used to unzip archives
    tmp_dir = 'C:\Users\206522262\Desktop\EODData\tmp';

    if (~exist(out_dir, 'dir'))
        mkdir(out_dir)
    end;
    
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
            temp = import_quotes_csv(fullfile(tmp_dir, csv(i).name));
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
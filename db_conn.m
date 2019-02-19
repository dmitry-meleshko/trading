function conn = db_conn()
    datasource = 'apical';
    load('db_config.mat');
    username = db_config{1};    
    password = db_config{2};
    driver = 'org.postgresql.Driver';
    url = 'jdbc:postgresql://localhost:5432/apical';

    conn = database(datasource,username,password,driver,url);
    return
end
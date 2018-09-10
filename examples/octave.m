pkg -auto install database-2.4.3.tar.gz


% ----- PostgreSQL with JDBC  ---- 
% Add jar file to classpath 
javaaddpath('postgresql-42.2.5.jar') 

% Username and password you chose when installing postgres 
props=javaObject('java.util.Properties'); 
props.setProperty("user", 'root'); 
%props.setProperty("password", ''); 

% Create database connection 
driver=javaObject('org.postgresql.Driver'); 
url='jdbc:postgres://root@localhost:26257/system?sslmode=disable'; 
conn=driver.connect(url, props)

% Test query 
sql='select username from "users"' 
ps=conn.prepareStatement(sql)
rs=ps.executeQuery()

% Retrieve results into  array 
count=0; 
result=struct; 
while rs.next() 
    count=count+1; 
    result(count)=char(rs.getString(1)); 
end
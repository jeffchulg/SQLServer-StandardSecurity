java -jar .\tools\combiner-0.0.1.jar -v -e -o .\dist\securityApplier_SQLServer.sql .\src\sqlserver\*.sql 2> build.log

java -jar .\tools\combiner-0.0.1.jar -v -e -o .\dist\SecurityManager.Testing.sql .\tests\*.sql 2> build.SecurityManager.Testing.log
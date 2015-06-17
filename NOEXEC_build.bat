mkdir logs

java -jar .\tools\combiner-0.0.1.jar -v -e -o .\dist\securityApplier_SQLServer.sql .\src\sqlserver\*.sql 2> logs/build.log

java -jar .\tools\combiner-0.0.1.jar -v -e -o .\dist\SecurityManager.Testing-DefineSecurity.sql .\tests\DefineSecurity\*.sql 2> logs/build.SecurityManager.Testing-DefineSecurity.log

java -jar .\tools\combiner-0.0.1.jar -v -e -o .\dist\SecurityManager.Testing-GenerateSecurityScript.sql .\tests\GenerateSecurityScript\*.sql 2> logs/build.SecurityManager.Testing-GenerateSecurityScript.log

java -jar .\tools\combiner-0.0.1.jar -v -e -o .\dist\SecurityManager.Testing-Cleanups.sql .\tests\Cleanups\*.sql 2> logs/build.SecurityManager.Testing-Cleanups.log
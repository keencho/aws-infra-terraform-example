#!/bin/bash

nohup java -jar \
-Dspring.profiles.active=test \
-Dserver.port=10000 \
-Ddb_url=SECRET \
-Ddb_username=SECRET \
-Ddb_password=SECRET \
app-admin.jar 1> /dev/null 2>&1 &

nohup java -jar \
-Dspring.profiles.active=test \
-Dserver.port=10010 \
-Ddb_url=SECRET \
-Ddb_username=SECRET \
-Ddb_password=SECRET \
app-user.jar 1> /dev/null 2>&1 &

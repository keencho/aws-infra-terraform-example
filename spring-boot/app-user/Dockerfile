FROM amazoncorretto:21

# 타임존 세팅
ENV TZ="Asia/Seoul"

ARG JAR_PATH

# 워크 디렉토리 세팅
WORKDIR /app-user/

# 빌드된 jar 파일 복사
COPY $JAR_PATH /app-user/app.jar

ENTRYPOINT ["java","-jar","app.jar"]
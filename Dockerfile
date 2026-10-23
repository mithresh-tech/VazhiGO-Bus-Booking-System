FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests
FROM tomcat:11-jdk21-temurin
RUN sed -i 's/port="8080"/port="10000"/' /usr/local/tomcat/conf/server.xml
COPY --from=build /app/target/online-bus-ticket-booking.war /usr/local/tomcat/webapps/online-bus-ticket-booking.war
EXPOSE 10000
CMD ["catalina.sh", "run"]

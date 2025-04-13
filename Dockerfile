FROM eclipse-temurin
ADD target/demo-0.0.1-SNAPSHOT.jar springbootApp.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "springbootApp.jar"]

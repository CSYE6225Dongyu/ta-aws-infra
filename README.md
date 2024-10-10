# WEBAPP CSYE6225

## Overview

This project is a simple web application built using **Java Spring Boot** that provides a health check endpoint `/healthz`. And a user register and update API with endpoint `/v1/user` and `/v1/user/self`. 

## Prerequisites

### 1.Develop Tools

To build and deploy this application locally, ensure you have the following tools installed on your system:

- **Java Development Kit (JDK)**: Version 11 or higher.
- **Apache Maven**: For building the application.
- **Git**: To clone the repository.

### 2.Database Configuration

This application is designed to connect to a database. You will need a database server like **MySQL**, **PostgreSQL**, or any other supported database for proper functionality. Ensure that your database is set up before running the application.

### 3.Spring boot Dependencies

The project uses the following Maven dependencies:

- **spring-boot-starter-data-jpa**
- **spring-boot-starter-web**
- **mysql-connector-j**
- **spring-boot-starter-test**

The `spring-boot-maven-plugin` is also included to package the application as a runnable JAR.

## Setup Instructions

### 1. Clone the Repository

First, clone the repository to your local machine using the following command:

```bash
git clone <REPOSITORY_URL or REPOSITORY_SSH>
```

### 2. Configure Application Properties

After cloning the repository, navigate to the `src/main/resources/` directory and create a new file named `application.properties`. This file is used for configuring the database connection and other settings required by Spring Boot.

#### Example

```properties
# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/mydb
spring.datasource.username=<your-database-username>
spring.datasource.password=<your-database-password>
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate Configuration
spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
```

> **Note**: The database URL format will vary based on the type of database you are using.

### 3. Build the Project

Navigate to the root directory of the project and run the following Maven command to build the project:

```
mvn clean install
```

This command will compile the code, run the tests, and package the application into a JAR file located in the `target/` directory.

### 4. Run the Application

After building the project, you can run the web application by executing the `WebApp` class. Use the following command:

```
mvn spring-boot:run
```

Or, you can run the JAR file directly:

```
java -jar target/<project-name>.jar
```

Replace `<project-name>` with the actual name of the packaged JAR file.

> **NOTE:** If use IntelliJ IDEA, run the WebApp class

### 5. Access the API

Once the application is running, you can access the health check API at:

```
http://localhost:8080/healthz
```

This endpoint will return different HTTP status codes based on the health of your database connection.

- **200 OK**: Request Success.
- **201 Created**: User created.
- **204 No content**: Update Successful
- **400 Bad Request**: If the request contains a payload.
- **401 Unauthorized**: Unauthorized user.
- **405 Method Not Allowed**: If an unsupported HTTP method is used.
- **503 Service Unavailable**: Database connection failed.
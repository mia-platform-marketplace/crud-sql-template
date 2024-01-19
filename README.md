# SQL CRUD Template

This is a template project to help you get started using the SQL CRUD service.

The project is set up to use the Mia-Platform SQL CRUD library. You can then provide a Data Source to connect to your preferred SQL database as will be shown in this documentation. 

# Environment variables

The following environment variables are used:

| Environment variable    | Description                                                                                                                                                                                                                                                                                                                                       |
|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| USERID_HEADER_KEY       | The name of the header that contains information of the user.                                                                                                                                                                                                                                                                                     | 
| HTTP_PORT               | The port on which the application server will serve status requests (default 3000).                                                                                                                                                                                                                                                               |
| API_PORT                | The port on which the application server will serve API requests (default 3001).                                                                                                                                                                                                                                                                  |
| SWAGGER_PORT            | The port on which the application server will serve swagger requests (default 5000).                                                                                                                                                                                                                                                              |
| TABLE_DEFINITION_FOLDER | Absolute path of a folder containing the tables JSON schemas.                                                                                                                                                                                                                                                                                     |
| LOG_LEVEL               | Specifies the log level to use.                                                                                                                                                                                                                                                                                                                   |
| DB_URL                  | Required. The connection string to connect to the database with username and password. <br/> Accepted formats: <br/> - [sqlserver\|postgresql]://[user[:[password]]@]host[:port][/database][?<key1>=<value1>[&<key2>=<value2>]] <br/> - jdbc:[sqlserver\|postgresql]://[host]:[port];databaseName=[db-name];user=[db-user];password=[db-password] |

# Configuration

## Define your tables

### JSONSchema Configuration

The tables should be included in separate JSON files in the folder defined with the environment variable `TABLE_DEFINITION_FOLDER`. Each tables object requires the following fields:

| Name             | Type               | Required | Default value | Description                                                                                                                                                                                                                                               |
|------------------|--------------------|----------|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| version          | String             | -        | -             | Configuration file version.                                                                                                                                                                                                                               |
| id               | String             | -        | -             | Additional identifier that can be associated to the collection definition.                                                                                                                                                                                |
| name             | String             | &check;  | -             | The name of the table.                                                                                                                                                                                                                                    |
| endpointBasePath | String             | &check;  | -             | The endpoint path, used as entry point to CRUD operations.                                                                                                                                                                                                |
| schema           | JSONSchemaStandard | &check;  | -             | The JSON Schema configuration of the fields to be included in the collection object. A complete description of its fields can be found in the [ _schema_](/library/src/main/resources/schema/tableJsonSchema.json) section of the collection JSON Schema. |
| metadata         | Object             | &check;  | -             | Object that contains service support metadata to handle standard fields such as updatedAt or updaterId. A complete description of its fields can be found [in the _metadata fields_ section](#metadata-fields).                                           |


An example of configuration can be found in the [Collections Definitions folder](./table-schemas).

#### Metadata fields
| Name           | Type    | Required | Default value | Description                                                                                                                   |
|----------------|---------|----------|---------------|-------------------------------------------------------------------------------------------------------------------------------|
| manageIdColumn | Boolean | &check;  | -             | Boolean flag that specifies if SQL tables use identity columns as identifier for records                              .       |
| createdAt      | String  | -        | -             | The name of the column you want to use to represent the created at moment - if not set is handled internally by the service.  |
| updatedAt      | String  | -        | -             | The name of the column you want to use to represent the updated at moment - if not set is handled internally by the service.  |
| timezone       | String  | -        | -             | The timezone to be used for date type fields. The format to be used is [Time Zone Database](https://www.iana.org/time-zones). |

# How to integrate with a SQL database

## Setup Nexus credentials

To use the Mia-Platform library you need access to the Mia-Platform Nexus repository. The project is already setup to use 
the repository but you have to provide valid access credentials.

To do this, create a copy of the `gradle.properties` file as follows:

```
cp gradle.properties gradle-local.properties
```

Then fill the requested credentials in the `gradle-local.properties` file.

## Install JDBC driver

To install a JDBC driver, update the `dependencies` section of the `app/build.gradle.kts` file by adding the required dependency.

For example add this line to use the JDBC driver for Oracle version 23:

```
implementation("com.oracle.database.jdbc:ojdbc8:23.3.0.23.09")
```

To install the dependency you can build the project in your IDE or run the following command in a terminal:

```bash
./gradlew installDist
```

## Configure environment variables

You can find in the `default.env` file, the list of environment variables to be configured as described in the previous chapter.
Default values are already provided.

You can create a copy of this file and just fill the `DB_URL` environment variable 
with the connection string of your database.

You can set the environment variables with this command:

```
cp default.env .env
```

```bash
set -a && source .env
```

## Update App file

Now you can modify the `App.kt` file in the `app/src/main/kotlin/eu/miaplatform/template/sqlcrud/` folder.

You have to provide to the `Server().start()` function a parameter that is the DataSource configured to connect to your database.

For example, if you used the Oracle JDBC driver, you can Configure a `OracleDataSource` instance with a valid connection string in a function like this:

```kotlin
private fun getDataSource(dbConnectionString: String): DataSource {
    val ds = OracleDataSource()
    ds.url = dbConnectionString
    return ds
}
```

and provide the DataSource like this:

```kotlin
fun main(): Unit = runBlocking {
    Server().start(getDataSource(System.getenv("DB_URL")))
}
```

Now you can build and run the application.

To run the application from the terminal run:
```bash
./gradlew clean run
```

The service will startup and expose CRUD APIs for the `books` table.
Please remember that the table must already exist in the database. If it is not present, create it with the following SQL query:

```SQL
CREATE TABLE books
(
    ID NUMBER,
    TITLE VARCHAR(100),
    AUTHOR VARCHAR(100),
    PRICE INTEGER,
    PUBLISHED BOOLEAN,
    SALESFORECAST INTEGER,
    LANGUAGE VARCHAR(100),
    RELEASEDATE TIMESTAMP,
    RELEASEPRICE DECIMAL(3),
    CREATORID VARCHAR(100),
    CREATEDAT TIMESTAMP,
    UPDATERID VARCHAR(100),
    UPDATEDAT TIMESTAMP,
    PRIMARY KEY(ID)
)
```

## Test CRUD

You can now make HTTP requests to the SQL CRUD service.

For example this request will create a record in the `books` table:

```bash
curl --request POST \
  --url http://localhost:3001/books \
  --header 'Content-Type: application/json' \
  --header 'userId: user' \
  --data '{
	"ID": 1,
	"TITLE": "book title",
	"AUTHOR": "book author"
        }'
```

This request will retrieve all records from the table:

```bash
curl http://localhost:3001/books/
```

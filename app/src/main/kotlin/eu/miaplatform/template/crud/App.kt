package eu.miaplatform.template.crud

import kotlinx.coroutines.runBlocking
import eu.miaplatform.sqlcrud.Server
import javax.sql.DataSource


fun main(): Unit = runBlocking {
    Server().start(getDataSource(System.getenv("DB_URL")))
}

private fun getDataSource(dbConnectionString: String): DataSource {
    // Setup here the DataSource you want to use to connect to the database
    // Examples are as follows:
    // val ds = OracleDataSource()
    // val ds = MSSQLDataSource()
    // val ds = PGDataSource()
    ds.url = dbConnectionString
    return ds
}

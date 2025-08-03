package app.likha.infrastructure;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.beans.factory.annotation.Autowired;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;

import static org.assertj.core.api.Assertions.*;

@SpringBootTest
@ActiveProfiles({ "test", "ci" })
@DisplayName("Basic Spring Database Connectivity Tests")
class BasicSpringDatabaseConnectivityTest {

    @Autowired
    private DataSource dataSource;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void setUp() throws Exception {
        // Verify database is running and accessible
        try (Connection connection = dataSource.getConnection()) {
            assertThat(connection.isValid(5))
                    .as("Database connection should be valid")
                    .isTrue();
        }
    }

    @Test
    @DisplayName("Should successfully connect to PostgreSQL database via Spring DataSource")
    void shouldConnectToDatabase() throws Exception {
        // Test basic database connectivity through Spring Boot
        try (Connection connection = dataSource.getConnection()) {
            assertThat(connection.isValid(5))
                    .as("Database connection should be valid")
                    .isTrue();

            DatabaseMetaData metaData = connection.getMetaData();
            assertThat(metaData.getDatabaseProductName())
                    .as("Should be connected to PostgreSQL")
                    .isEqualTo("PostgreSQL");
        }
    }

    @Test
    @DisplayName("Should have basic database tables available")
    void shouldHaveBasicTables() {
        // Verify that essential tables exist (from earlier migrations)
        String[] basicTables = {
                "tenants",
                "business_contracts",
                "contract_files"
        };

        for (String tableName : basicTables) {
            Integer tableCount = jdbcTemplate.queryForObject(
                    "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = ? AND table_schema = 'public'",
                    Integer.class,
                    tableName);

            assertThat(tableCount)
                    .as("Table '%s' should exist in public schema", tableName)
                    .isEqualTo(1);
        }
    }

    @Test
    @DisplayName("Should validate Spring JDBC Template functionality")
    void shouldValidateJdbcTemplate() {
        // Test that Spring's JdbcTemplate works correctly
        String result = jdbcTemplate.queryForObject(
                "SELECT 'Spring JDBC Test Success' as test_result",
                String.class);

        assertThat(result)
                .as("JdbcTemplate should execute queries successfully")
                .isEqualTo("Spring JDBC Test Success");
    }

    @Test
    @DisplayName("Should validate connection pool configuration")
    void shouldValidateConnectionPoolConfiguration() throws Exception {
        // Test multiple concurrent connections (basic connection pool validation)
        try (Connection conn1 = dataSource.getConnection();
                Connection conn2 = dataSource.getConnection();
                Connection conn3 = dataSource.getConnection()) {

            assertThat(conn1.isValid(5))
                    .as("First connection should be valid")
                    .isTrue();

            assertThat(conn2.isValid(5))
                    .as("Second connection should be valid")
                    .isTrue();

            assertThat(conn3.isValid(5))
                    .as("Third connection should be valid")
                    .isTrue();

            // All connections should be different instances
            assertThat(conn1)
                    .as("Connections should be different instances")
                    .isNotSameAs(conn2)
                    .isNotSameAs(conn3);
        }
    }

    @Test
    @DisplayName("Should have Flyway schema history table")
    void shouldHaveFlywaySchemaHistory() {
        // Even with Flyway disabled in tests, the table should exist from dev setup
        Integer tableCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'flyway_schema_history' AND table_schema = 'public'",
                Integer.class);

        assertThat(tableCount)
                .as("Flyway schema history table should exist")
                .isEqualTo(1);
    }
}
package de.pawsmatch;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import java.sql.*;
import static org.junit.jupiter.api.Assertions.*;

@EnabledIfEnvironmentVariable(named = "JDBC_INTEGRATION_TEST", matches = "true")
class JdbcUebungTest {
    private long standorte(Connection c) throws SQLException {
        try (Statement s = c.createStatement(); ResultSet rs = s.executeQuery("SELECT count(*) FROM tierheim")) {
            rs.next();
            return rs.getLong(1);
        }
    }

    @Test
    void liestVorhandeneDemoUndRolltSchreibzugriffZurueck() throws Exception {
        try (Connection c = JdbcUebung.verbinden()) {
            var tiere = JdbcUebung.ladeTiere(c, "verfuegbar");
            assertEquals(13, tiere.size(), "Test erwartet die frische Gesamtdemo aus build_demo.sql");
            assertTrue(tiere.stream().allMatch(t -> t.status().equals("verfuegbar") && t.tierheim() != null));
            assertTrue(JdbcUebung.ladeTiere(c, "verfuegbar' OR '1'='1").isEmpty());
            long vorher = standorte(c);
            var result = JdbcUebung.schreibDemo(c);
            assertEquals(1, result.geaenderteZeilen());
            assertTrue(result.aenderungGelesen());
            assertTrue(result.zurueckgerollt());
            assertEquals(vorher, standorte(c));
            assertTrue(c.getAutoCommit());
        }
    }
}

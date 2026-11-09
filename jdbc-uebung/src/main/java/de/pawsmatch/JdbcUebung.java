package de.pawsmatch;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public final class JdbcUebung {
    public record Tier(int id, String name, String tierart, String status, String tierheim) {}
    public record SchreibErgebnis(int standortId, int geaenderteZeilen, boolean aenderungGelesen, boolean zurueckgerollt) {}

    public static Connection verbinden() throws SQLException {
        return DriverManager.getConnection(env("DB_URL"), env("DB_USER"), env("DB_PASSWORD"));
    }

    private static String env(String name) {
        String value = System.getenv(name);
        if (value == null || value.isBlank()) throw new IllegalStateException("Umgebungsvariable fehlt: " + name);
        return value;
    }

    public static List<Tier> ladeTiere(Connection connection, String status) throws SQLException {
        String sql = """
                SELECT t.tier_id, t.name, t.tierart, t.status, h.name AS tierheim_name
                FROM tier t JOIN tierheim h ON h.tierheim_id = t.tierheim_id
                WHERE t.status = ? ORDER BY t.tier_id
                """;
        List<Tier> tiere = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    tiere.add(new Tier(rs.getInt("tier_id"), rs.getString("name"),
                            rs.getString("tierart"), rs.getString("status"), rs.getString("tierheim_name")));
                }
            }
        }
        return tiere;
    }

    public static SchreibErgebnis schreibDemo(Connection connection) throws SQLException {
        if (!connection.getAutoCommit()) throw new SQLException("Schreibdemo benoetigt eine Verbindung ohne laufende Transaktion.");
        int id;
        int geaendert;
        boolean gelesen;
        connection.setAutoCommit(false);
        try {
            try (PreparedStatement ps = connection.prepareStatement(
                    "INSERT INTO tierheim(name, ort) VALUES (?, ?) RETURNING tierheim_id")) {
                ps.setString(1, "JDBC-Demo-" + UUID.randomUUID());
                ps.setString(2, "Fiktiver Demo-Ort");
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) throw new SQLException("Keine erzeugte ID erhalten.");
                    id = rs.getInt(1);
                }
            }
            try (PreparedStatement ps = connection.prepareStatement("UPDATE tierheim SET ort = ? WHERE tierheim_id = ?")) {
                ps.setString(1, "Geaenderter Demo-Ort");
                ps.setInt(2, id);
                geaendert = ps.executeUpdate();
                if (geaendert != 1) throw new SQLException("Genau eine geaenderte Zeile erwartet.");
            }
            try (PreparedStatement ps = connection.prepareStatement("SELECT ort FROM tierheim WHERE tierheim_id = ?")) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    gelesen = rs.next() && "Geaenderter Demo-Ort".equals(rs.getString(1));
                    if (!gelesen) throw new SQLException("Aenderung konnte nicht zurueckgelesen werden.");
                }
            }
        } finally {
            connection.rollback();
            connection.setAutoCommit(true);
        }
        boolean entfernt;
        try (PreparedStatement ps = connection.prepareStatement("SELECT 1 FROM tierheim WHERE tierheim_id = ?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) { entfernt = !rs.next(); }
        }
        if (!entfernt) throw new SQLException("Teststandort trotz Rollback vorhanden.");
        return new SchreibErgebnis(id, geaendert, gelesen, entfernt);
    }

    public static void main(String[] args) throws Exception {
        String status = args.length == 0 ? "verfuegbar" : args[0];
        try (Connection connection = verbinden()) {
            System.out.println("JDBC-Verbindung erfolgreich.");
            List<Tier> tiere = ladeTiere(connection, status);
            for (Tier tier : tiere) {
                System.out.printf("%d | %s | %s | %s | %s%n", tier.id(), tier.name(), tier.tierart(), tier.status(), tier.tierheim());
            }
            System.out.println("Gefundene Tiere: " + tiere.size());
            SchreibErgebnis result = schreibDemo(connection);
            System.out.println("Teststandort-ID: " + result.standortId());
            System.out.println("Geaenderte Zeilen: " + result.geaenderteZeilen());
            System.out.println("Aenderung zurueckgelesen: " + result.aenderungGelesen());
            System.out.println("Schreibdemo zurueckgerollt: " + result.zurueckgerollt());
        }
    }
}

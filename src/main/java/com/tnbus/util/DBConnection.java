
package com.tnbus.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
            getEnv("DB_URL",
                    "jdbc:mysql://localhost:3306/bus_booking_db"
                    + "?useSSL=false"
                    + "&allowPublicKeyRetrieval=true"
                    + "&serverTimezone=Asia/Kolkata");

    private static final String USERNAME =
            getEnv("DB_USERNAME", "root");

    private static final String PASSWORD =
            getEnv("DB_PASSWORD", "root");

    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC driver is missing", e);
        }

        return DriverManager.getConnection(
                URL, USERNAME, PASSWORD);
    }
    
    private static String getEnv(String key, String defaultValue) {
        String value = System.getenv(key);
        return (value == null || value.isBlank())
                ? defaultValue : value;
    }
}

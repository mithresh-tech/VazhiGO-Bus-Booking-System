package com.tnbus.dao;

import com.tnbus.model.Admin;
import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminDAO {

    public Admin loginAdmin(String email, String password) throws SQLException {

        String sql = "SELECT * FROM admin "
                + "WHERE email = ? AND password = ? AND status = 'ACTIVE'";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, email);
            statement.setString(2, password);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    return mapAdmin(resultSet);
                }
            }
        }

        return null;
    }

    public Admin getAdminById(long adminId) throws SQLException {

        String sql = "SELECT * FROM admin WHERE admin_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setLong(1, adminId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    return mapAdmin(resultSet);
                }
            }
        }

        return null;
    }

    public List<Admin> getAllAdmins() throws SQLException {

        List<Admin> admins = new ArrayList<>();

        String sql = "SELECT * FROM admin ORDER BY admin_id";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                admins.add(mapAdmin(resultSet));
            }
        }

        return admins;
    }

    private Admin mapAdmin(ResultSet resultSet) throws SQLException {

        Admin admin = new Admin();

        admin.setAdminId(resultSet.getLong("admin_id"));
        admin.setAdminName(resultSet.getString("admin_name"));
        admin.setEmail(resultSet.getString("email"));
        admin.setPassword(resultSet.getString("password"));
        admin.setStatus(resultSet.getString("status"));

        return admin;
    }
}
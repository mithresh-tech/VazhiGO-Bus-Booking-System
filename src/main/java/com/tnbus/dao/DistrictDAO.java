package com.tnbus.dao;

import com.tnbus.model.District;
import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DistrictDAO {

    public List<District> getAllDistricts() throws SQLException {

        List<District> districts = new ArrayList<>();

        String sql = "SELECT * FROM district "
                + "WHERE status = 'ACTIVE' ORDER BY district_name";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                District district = new District();

                district.setDistrictId(resultSet.getInt("district_id"));
                district.setDistrictName(resultSet.getString("district_name"));
                district.setStatus(resultSet.getString("status"));

                districts.add(district);
            }
        }

        return districts;
    }

    public District getDistrictById(int districtId) throws SQLException {

        String sql = "SELECT * FROM district WHERE district_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, districtId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {

                    District district = new District();

                    district.setDistrictId(resultSet.getInt("district_id"));
                    district.setDistrictName(resultSet.getString("district_name"));
                    district.setStatus(resultSet.getString("status"));

                    return district;
                }
            }
        }

        return null;
    }
}
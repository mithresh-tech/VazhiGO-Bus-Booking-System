package com.tnbus.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.tnbus.model.BusAmenity;
import com.tnbus.util.DBConnection;

public class BusAmenityDAO {

    // Retrieve configured amenities for a specific bus.
    // Returns null when no configuration exists.

    public BusAmenity getAmenitiesByBusId(int busId)
            throws SQLException {

        String sql = """
            SELECT
                wifi,
                charging,
                food,
                restroom,
                blanket,
                water_bottle
            FROM bus_amenity
            WHERE bus_id = ?
            """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, busId);

            try (ResultSet rs = statement.executeQuery()) {

                if (rs.next()) {

                    BusAmenity amenity = new BusAmenity();

                    amenity.setWifi(rs.getBoolean("wifi"));
                    amenity.setCharging(rs.getBoolean("charging"));
                    amenity.setFood(rs.getBoolean("food"));
                    amenity.setRestroom(rs.getBoolean("restroom"));
                    amenity.setBlanket(rs.getBoolean("blanket"));
                    amenity.setWaterBottle(
                            rs.getBoolean("water_bottle"));

                    return amenity;
                }
            }
        }

        return null;
    }
}
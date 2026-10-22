package com.tnbus.dao;

import com.tnbus.model.City;
import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CityDAO {

    public List<City> getAllCities() throws SQLException {

        List<City> cities = new ArrayList<>();

        String sql = "SELECT * FROM city "
                + "WHERE status = 'ACTIVE' ORDER BY city_name";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                City city = new City();

                city.setCityId(resultSet.getInt("city_id"));
                city.setDistrictId(resultSet.getInt("district_id"));
                city.setCityName(resultSet.getString("city_name"));
                city.setStatus(resultSet.getString("status"));

                cities.add(city);
            }
        }

        return cities;
    }

    public List<City> getCitiesByDistrict(int districtId) throws SQLException {

        List<City> cities = new ArrayList<>();

        String sql = "SELECT * FROM city "
                + "WHERE district_id = ? AND status = 'ACTIVE' "
                + "ORDER BY city_name";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, districtId);

            try (ResultSet resultSet = statement.executeQuery()) {

                while (resultSet.next()) {

                    City city = new City();

                    city.setCityId(resultSet.getInt("city_id"));
                    city.setDistrictId(resultSet.getInt("district_id"));
                    city.setCityName(resultSet.getString("city_name"));
                    city.setStatus(resultSet.getString("status"));

                    cities.add(city);
                }
            }
        }

        return cities;
    }

    public City getCityById(int cityId) throws SQLException {

        String sql = "SELECT * FROM city WHERE city_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, cityId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {

                    City city = new City();

                    city.setCityId(resultSet.getInt("city_id"));
                    city.setDistrictId(resultSet.getInt("district_id"));
                    city.setCityName(resultSet.getString("city_name"));
                    city.setStatus(resultSet.getString("status"));

                    return city;
                }
            }
        }

        return null;
    }
}
package com.tnbus.dao;

import com.tnbus.model.Route;
import com.tnbus.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RouteDAO {

    public boolean addRoute(Route route) throws SQLException {

        String sql = "INSERT INTO route "
                + "(source_city_id, destination_city_id, distance_km, status) "
                + "VALUES (?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, route.getSourceCityId());
            statement.setInt(2, route.getDestinationCityId());
            statement.setBigDecimal(3, route.getDistanceKm());
            statement.setString(4, route.getStatus());

            return statement.executeUpdate() > 0;
        }
    }

    public boolean updateRoute(Route route) throws SQLException {

        String sql = "UPDATE route SET source_city_id = ?, "
                + "destination_city_id = ?, distance_km = ?, status = ? "
                + "WHERE route_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, route.getSourceCityId());
            statement.setInt(2, route.getDestinationCityId());
            statement.setBigDecimal(3, route.getDistanceKm());
            statement.setString(4, route.getStatus());
            statement.setInt(5, route.getRouteId());

            return statement.executeUpdate() > 0;
        }
    }

    public List<Route> getAllRoutes() throws SQLException {

        List<Route> routes = new ArrayList<>();

        String sql = "SELECT * FROM route ORDER BY route_id";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                Route route = new Route();

                route.setRouteId(resultSet.getInt("route_id"));
                route.setSourceCityId(resultSet.getInt("source_city_id"));
                route.setDestinationCityId(resultSet.getInt("destination_city_id"));
                route.setDistanceKm(resultSet.getBigDecimal("distance_km"));
                route.setStatus(resultSet.getString("status"));

                routes.add(route);
            }
        }

        return routes;
    }

    public Route getRouteById(int routeId) throws SQLException {

        String sql = "SELECT * FROM route WHERE route_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, routeId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {

                    Route route = new Route();

                    route.setRouteId(resultSet.getInt("route_id"));
                    route.setSourceCityId(resultSet.getInt("source_city_id"));
                    route.setDestinationCityId(resultSet.getInt("destination_city_id"));
                    route.setDistanceKm(resultSet.getBigDecimal("distance_km"));
                    route.setStatus(resultSet.getString("status"));

                    return route;
                }
            }
        }

        return null;
    }
}
package com.tnbus.service;

import com.tnbus.dao.RouteDAO;
import com.tnbus.model.Route;

import java.sql.SQLException;
import java.util.List;

public class RouteService {

    private final RouteDAO routeDAO;

    public RouteService() {
        this.routeDAO = new RouteDAO();
    }

    public boolean addRoute(Route route) throws SQLException {

        if (route == null) {
            return false;
        }

        if (route.getSourceCityId() <= 0
                || route.getDestinationCityId() <= 0) {
            return false;
        }

        if (route.getSourceCityId()
                == route.getDestinationCityId()) {
            return false;
        }

        if (route.getStatus() == null
                || route.getStatus().isBlank()) {
            route.setStatus("ACTIVE");
        }

        return routeDAO.addRoute(route);
    }

    public boolean updateRoute(Route route)
            throws SQLException {

        if (route == null || route.getRouteId() <= 0) {
            return false;
        }

        return routeDAO.updateRoute(route);
    }

    public Route getRouteById(int routeId)
            throws SQLException {

        if (routeId <= 0) {
            return null;
        }

        return routeDAO.getRouteById(routeId);
    }

    public List<Route> getAllRoutes()
            throws SQLException {

        return routeDAO.getAllRoutes();
    }
}
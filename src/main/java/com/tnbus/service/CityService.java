package com.tnbus.service;

import com.tnbus.dao.CityDAO;
import com.tnbus.model.City;

import java.sql.SQLException;
import java.util.List;

public class CityService {

    private final CityDAO cityDAO;

    public CityService() {
        this.cityDAO = new CityDAO();
    }

    public List<City> getAllCities() throws SQLException {
        return cityDAO.getAllCities();
    }

    public List<City> getCitiesByDistrict(int districtId)
            throws SQLException {

        if (districtId <= 0) {
            return List.of();
        }

        return cityDAO.getCitiesByDistrict(districtId);
    }

    public City getCityById(int cityId) throws SQLException {

        if (cityId <= 0) {
            return null;
        }

        return cityDAO.getCityById(cityId);
    }
}
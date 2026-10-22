package com.tnbus.service;

import com.tnbus.dao.DistrictDAO;
import com.tnbus.exception.BusNotFoundException;
import com.tnbus.model.District;

import java.sql.SQLException;
import java.util.List;

public class DistrictService {

    private final DistrictDAO districtDAO;

    public DistrictService() {
        this.districtDAO = new DistrictDAO();
    }

    public List<District> getAllDistricts() throws SQLException {
        return districtDAO.getAllDistricts();
    }

    public District getDistrictById(int districtId)
            throws SQLException, BusNotFoundException {

        if (districtId <= 0) {
            throw new BusNotFoundException("Invalid district ID.");
        }

        District district = districtDAO.getDistrictById(districtId);

        if (district == null) {
            throw new BusNotFoundException("District not found.");
        }

        return district;
    }
}
package com.tnbus.service;

import com.tnbus.dao.BusDAO;
import com.tnbus.exception.BusNotFoundException;
import com.tnbus.model.Bus;

import java.sql.SQLException;
import java.util.List;

public class BusService {

    private final BusDAO busDAO;

    public BusService() {
        this.busDAO = new BusDAO();
    }

    // EXISTING METHODS

    public boolean addBus(Bus bus) throws SQLException {

        if (bus == null) {
            return false;
        }

        if (bus.getBusNumber() == null
                || bus.getBusNumber().isBlank()) {
            return false;
        }

        if (bus.getBusName() == null
                || bus.getBusName().isBlank()) {
            return false;
        }

        if (bus.getTotalSeats() <= 0) {
            return false;
        }

        if (bus.getStatus() == null
                || bus.getStatus().isBlank()) {
            bus.setStatus("ACTIVE");
        }

        return busDAO.addBus(bus);
    }

    public boolean updateBus(Bus bus) throws SQLException {

        if (bus == null || bus.getBusId() <= 0) {
            return false;
        }

        return busDAO.updateBus(bus);
    }

    public boolean deleteBus(int busId)
            throws SQLException, BusNotFoundException {

        if (busId <= 0) {
            throw new BusNotFoundException("Invalid bus ID.");
        }

        Bus bus = busDAO.getBusById(busId);

        if (bus == null) {
            throw new BusNotFoundException("Bus not found.");
        }

        return busDAO.deleteBus(busId);
    }

    public Bus getBusById(int busId)
            throws SQLException, BusNotFoundException {

        if (busId <= 0) {
            throw new BusNotFoundException("Invalid bus ID.");
        }

        Bus bus = busDAO.getBusById(busId);

        if (bus == null) {
            throw new BusNotFoundException("Bus not found.");
        }

        return bus;
    }

    public List<Bus> getAllBuses() throws SQLException {
        return busDAO.getAllBuses();
    }

    // STEP 25: ADMIN BUS MANAGEMENT

    private void validateBusDetails(Bus bus) {

        if (bus == null) {
            throw new IllegalArgumentException(
                    "Bus details are required.");
        }

        if (bus.getBusNumber() == null
                || bus.getBusNumber().isBlank()
                || bus.getBusNumber().length() > 30) {

            throw new IllegalArgumentException(
                    "Enter a valid bus number (maximum 30 characters).");
        }

        if (bus.getBusName() == null
                || bus.getBusName().isBlank()
                || bus.getBusName().length() > 100) {

            throw new IllegalArgumentException(
                    "Enter a valid bus name (maximum 100 characters).");
        }

        if (bus.getBusType() == null
                || bus.getBusType().isBlank()
                || bus.getBusType().length() > 50) {

            throw new IllegalArgumentException(
                    "Enter a valid bus type (maximum 50 characters).");
        }
    }

    public boolean addAdminBus(Bus bus) throws SQLException {

        validateBusDetails(bus);

        if (bus.getTotalSeats() < 1
                || bus.getTotalSeats() > 100) {

            throw new IllegalArgumentException(
                    "Total seats must be between 1 and 100.");
        }

        // Newly created buses require seat-layout configuration.
        bus.setStatus("INACTIVE");

        return busDAO.addAdminBus(bus);
    }

    public boolean updateAdminBusDetails(Bus bus)
            throws SQLException, BusNotFoundException {

        validateBusDetails(bus);

        getBusById(bus.getBusId());

        return busDAO.updateAdminBusDetails(bus);
    }

    public boolean updateAdminBusStatus(
            int busId,
            String status)
            throws SQLException, BusNotFoundException {

        Bus bus = getBusById(busId);

        if (!"ACTIVE".equals(status)
                && !"INACTIVE".equals(status)) {

            throw new IllegalArgumentException(
                    "Invalid bus status.");
        }

        if (status.equals(bus.getStatus())) {
            return true;
        }

        if ("INACTIVE".equals(status)
                && busDAO.hasCurrentOrFutureSchedules(busId)) {

            throw new IllegalArgumentException(
                    "This bus has current or future schedules. "
                    + "Review its schedules before deactivation.");
        }

        if ("ACTIVE".equals(status)) {

            int activeSeats = busDAO.countSeats(busId);

            if (activeSeats != bus.getTotalSeats()) {

                throw new IllegalArgumentException(
                        "Cannot activate bus. Expected "
                        + bus.getTotalSeats()
                        + " active seats, but found "
                        + activeSeats
                        + ". Configure the seat layout first.");
            }
        }

        return busDAO.updateAdminBusStatus(busId, status);
    }
}
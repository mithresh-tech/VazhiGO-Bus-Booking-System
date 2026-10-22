package com.tnbus.service;

import com.tnbus.dao.BusScheduleDAO;

import com.tnbus.exception.BusNotFoundException;
import com.tnbus.model.BusSchedule;

import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.math.BigDecimal;

public class BusScheduleService {

    private final BusScheduleDAO busScheduleDAO;

    public BusScheduleService() {
        this.busScheduleDAO = new BusScheduleDAO();
    }

    public boolean addSchedule(BusSchedule schedule)
            throws SQLException {

        if (schedule == null) {
            return false;
        }

        if (schedule.getBusId() <= 0
                || schedule.getRouteId() <= 0) {
            return false;
        }

        if (schedule.getTravelDate() == null
                || schedule.getDepartureTime() == null
                || schedule.getArrivalTime() == null) {
            return false;
        }

        if (schedule.getFare() == null
                || schedule.getFare().signum() < 0) {
            return false;
        }

        if (schedule.getStatus() == null
                || schedule.getStatus().isBlank()) {

            schedule.setStatus("SCHEDULED");
        }

        return busScheduleDAO.addSchedule(schedule);
    }

    public List<BusSchedule> searchSchedules(
            int sourceCityId,
            int destinationCityId,
            LocalDate travelDate)
            throws SQLException {

        if (sourceCityId <= 0
                || destinationCityId <= 0
                || sourceCityId == destinationCityId
                || travelDate == null) {

            return List.of();
        }

        return busScheduleDAO.searchSchedules(
                sourceCityId,
                destinationCityId,
                Date.valueOf(travelDate));
    }

    public BusSchedule getScheduleById(int scheduleId)
            throws SQLException, BusNotFoundException {

        if (scheduleId <= 0) {
            throw new BusNotFoundException(
                    "Invalid schedule ID.");
        }

        BusSchedule schedule =
                busScheduleDAO.getScheduleById(scheduleId);

        if (schedule == null) {
            throw new BusNotFoundException(
                    "Bus schedule not found.");
        }

        return schedule;
    }

    public List<BusSchedule> getAllSchedules()
            throws SQLException {

        return busScheduleDAO.getAllSchedules();
    }
    
 // ==========================================
 // STEP 26 - ADMIN SCHEDULE VALIDATION
 // ==========================================

 private void validateAdminSchedule(BusSchedule schedule) {

     if (schedule == null) {
         throw new IllegalArgumentException(
                 "Schedule details are required.");
     }

     if (schedule.getBusId() <= 0) {
         throw new IllegalArgumentException(
                 "Please select a valid bus.");
     }

     if (schedule.getRouteId() <= 0) {
         throw new IllegalArgumentException(
                 "Please select a valid route.");
     }

     if (schedule.getTravelDate() == null
             || schedule.getTravelDate().isBefore(LocalDate.now())) {

         throw new IllegalArgumentException(
                 "Travel date cannot be in the past.");
     }

     if (schedule.getDepartureTime() == null
             || schedule.getArrivalTime() == null) {

         throw new IllegalArgumentException(
                 "Departure and arrival times are required.");
     }

     if (schedule.getDepartureTime()
             .equals(schedule.getArrivalTime())) {

         throw new IllegalArgumentException(
                 "Departure and arrival times cannot be identical.");
     }

     validateFare(schedule.getFare(), "Base fare", true);

     validateFare(
             schedule.getUpperDeckFare(), "Upper deck fare", false);

     validateFare(
             schedule.getLowerDeckFare(), "Lower deck fare", false);

     validateFare(
             schedule.getDoubleUpperFare(), "Double upper fare", false);

     validateFare(
             schedule.getDoubleLowerFare(), "Double lower fare", false);

     validateFare(
             schedule.getSingleUpperFare(), "Single upper fare", false);

     validateFare(
             schedule.getSingleLowerFare(), "Single lower fare", false);

     validateFare(
             schedule.getSeaterFare(), "Seater fare", false);
 }


 private void validateFare(
         BigDecimal fare,
         String fieldName,
         boolean required) {

     if (fare == null) {

         if (required) {
             throw new IllegalArgumentException(
                     fieldName + " is required.");
         }

         return;
     }

     if (fare.signum() < 0
             || fare.scale() > 2
             || fare.compareTo(new BigDecimal("99999999.99")) > 0) {

         throw new IllegalArgumentException(
                 fieldName + " must be a valid non-negative amount.");
     }
 }


 // ADMIN UPDATE

 public boolean updateAdminSchedule(BusSchedule schedule)
         throws SQLException {

     validateAdminSchedule(schedule);

     if (schedule.getScheduleId() <= 0) {
         throw new IllegalArgumentException(
                 "Invalid schedule ID.");
     }

     BusSchedule existing =
             busScheduleDAO.getScheduleById(
                     schedule.getScheduleId());

     if (existing == null) {
         throw new IllegalArgumentException(
                 "Schedule not found.");
     }

     if (!"SCHEDULED".equals(existing.getStatus())) {
         throw new IllegalArgumentException(
                 "Only scheduled journeys can be edited.");
     }

     if (busScheduleDAO.hasBookingHistory(
             schedule.getScheduleId())) {

         throw new IllegalArgumentException(
                 "This schedule has booking history. "
                 + "Its journey details and fares cannot be modified.");
     }

     if (!busScheduleDAO.isBusReadyForScheduling(
             schedule.getBusId())) {

         throw new IllegalArgumentException(
                 "The selected bus is inactive or its "
                 + "seat configuration is incomplete.");
     }

     if (!busScheduleDAO.isRouteActive(
             schedule.getRouteId())) {

         throw new IllegalArgumentException(
                 "The selected route is not active.");
     }

     if (busScheduleDAO.hasDuplicateSchedule(
             schedule.getBusId(),
             schedule.getTravelDate(),
             schedule.getDepartureTime(),
             schedule.getScheduleId())) {

         throw new IllegalArgumentException(
                 "This bus already has a journey scheduled "
                 + "for the selected date and departure time.");
     }

     return busScheduleDAO.updateAdminSchedule(schedule);
 }


 // ADMIN CANCELLATION

 public boolean cancelAdminSchedule(int scheduleId)
         throws SQLException {

     if (scheduleId <= 0) {
         throw new IllegalArgumentException(
                 "Invalid schedule ID.");
     }

     BusSchedule existing =
             busScheduleDAO.getScheduleById(scheduleId);

     if (existing == null) {
         throw new IllegalArgumentException(
                 "Schedule not found.");
     }

     if (!"SCHEDULED".equals(existing.getStatus())) {
         throw new IllegalArgumentException(
                 "This schedule is not available for cancellation.");
     }

     if (busScheduleDAO.hasBookingHistory(scheduleId)) {

         throw new IllegalArgumentException(
                 "This schedule has booking history. "
                 + "Administrative cancellation is blocked "
                 + "to protect passenger records.");
     }

     return busScheduleDAO.cancelAdminSchedule(scheduleId);
 }
 
//==========================================
//STEP 26B - ADMIN CREATE
//==========================================

public boolean addAdminSchedule(BusSchedule schedule)
      throws SQLException {

  validateAdminSchedule(schedule);

  if (!busScheduleDAO.isBusReadyForScheduling(
          schedule.getBusId())) {

      throw new IllegalArgumentException(
              "Selected bus is inactive or its seat layout is incomplete.");
  }

  if (!busScheduleDAO.isRouteActive(
          schedule.getRouteId())) {

      throw new IllegalArgumentException(
              "Selected route is inactive.");
  }

  schedule.setStatus("SCHEDULED");

  return busScheduleDAO.addAdminSchedule(schedule);
}


//==========================================
//STEP 26B - TRANSACTION-SAFE ADMIN EDIT
//==========================================

public boolean updateAdminScheduleSafely(BusSchedule schedule)
      throws SQLException {

  validateAdminSchedule(schedule);

  if (schedule.getScheduleId() <= 0) {

      throw new IllegalArgumentException(
              "Invalid schedule ID.");
  }

  return busScheduleDAO.updateAdminScheduleSafely(schedule);

}
}
package com.tnbus.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

import com.tnbus.model.BusSchedule;
import com.tnbus.util.DBConnection;

public class BusScheduleDAO {

    // ==========================================
    // ADD SCHEDULE
    // ==========================================

    public boolean addSchedule(BusSchedule schedule)
            throws SQLException {

        String sql = "INSERT INTO bus_schedule "
                + "(bus_id, route_id, travel_date, departure_time, "
                + "arrival_time, fare, upper_deck_fare, lower_deck_fare, "
                + "double_upper_fare, double_lower_fare, "
                + "single_upper_fare, single_lower_fare, "
                + "seater_fare, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, schedule.getBusId());
            statement.setInt(2, schedule.getRouteId());

            statement.setDate(
                    3, Date.valueOf(schedule.getTravelDate()));

            statement.setTime(
                    4, Time.valueOf(schedule.getDepartureTime()));

            statement.setTime(
                    5, Time.valueOf(schedule.getArrivalTime()));

            // Existing pricing
            statement.setBigDecimal(6, schedule.getFare());

            statement.setBigDecimal(
                    7, schedule.getUpperDeckFare());

            statement.setBigDecimal(
                    8, schedule.getLowerDeckFare());

            // New category-wise pricing
            statement.setBigDecimal(
                    9, schedule.getDoubleUpperFare());

            statement.setBigDecimal(
                    10, schedule.getDoubleLowerFare());

            statement.setBigDecimal(
                    11, schedule.getSingleUpperFare());

            statement.setBigDecimal(
                    12, schedule.getSingleLowerFare());

            statement.setBigDecimal(
                    13, schedule.getSeaterFare());

            statement.setString(14, schedule.getStatus());

            return statement.executeUpdate() > 0;
        }
    }

    // ==========================================
    // SEARCH SCHEDULES
    // ==========================================

    public List<BusSchedule> searchSchedules(
            int sourceCityId,
            int destinationCityId,
            Date travelDate) throws SQLException {

        List<BusSchedule> schedules = new ArrayList<>();

        String sql = "SELECT bs.* "
                + "FROM bus_schedule bs "
                + "JOIN route r ON bs.route_id = r.route_id "
                + "WHERE r.source_city_id = ? "
                + "AND r.destination_city_id = ? "
                + "AND bs.travel_date = ? "
                + "AND bs.status = 'SCHEDULED' "
                + "ORDER BY bs.departure_time";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, sourceCityId);
            statement.setInt(2, destinationCityId);
            statement.setDate(3, travelDate);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                while (resultSet.next()) {
                    schedules.add(mapSchedule(resultSet));
                }
            }
        }

        return schedules;
    }

    // ==========================================
    // GET SCHEDULE BY ID
    // ==========================================

    public BusSchedule getScheduleById(int scheduleId)
            throws SQLException {

        String sql = "SELECT * FROM bus_schedule "
                + "WHERE schedule_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setInt(1, scheduleId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                if (resultSet.next()) {
                    return mapSchedule(resultSet);
                }
            }
        }

        return null;
    }

    // ==========================================
    // GET ALL SCHEDULES
    // ==========================================

    public List<BusSchedule> getAllSchedules()
            throws SQLException {

        List<BusSchedule> schedules = new ArrayList<>();

        String sql = "SELECT * FROM bus_schedule "
                + "ORDER BY travel_date, departure_time";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                schedules.add(mapSchedule(resultSet));
            }
        }

        return schedules;
    }

    // ==========================================
    // MAP DATABASE RESULT TO MODEL
    // ==========================================

    private BusSchedule mapSchedule(ResultSet resultSet)
            throws SQLException {

        BusSchedule schedule = new BusSchedule();

        schedule.setScheduleId(
                resultSet.getInt("schedule_id"));

        schedule.setBusId(
                resultSet.getInt("bus_id"));

        schedule.setRouteId(
                resultSet.getInt("route_id"));

        schedule.setTravelDate(
                resultSet.getDate("travel_date").toLocalDate());

        schedule.setDepartureTime(
                resultSet.getTime("departure_time").toLocalTime());

        schedule.setArrivalTime(
                resultSet.getTime("arrival_time").toLocalTime());

        // Existing pricing
        schedule.setFare(
                resultSet.getBigDecimal("fare"));

        schedule.setUpperDeckFare(
                resultSet.getBigDecimal("upper_deck_fare"));

        schedule.setLowerDeckFare(
                resultSet.getBigDecimal("lower_deck_fare"));

        // New category-wise pricing
        schedule.setDoubleUpperFare(
                resultSet.getBigDecimal("double_upper_fare"));

        schedule.setDoubleLowerFare(
                resultSet.getBigDecimal("double_lower_fare"));

        schedule.setSingleUpperFare(
                resultSet.getBigDecimal("single_upper_fare"));

        schedule.setSingleLowerFare(
                resultSet.getBigDecimal("single_lower_fare"));

        schedule.setSeaterFare(
                resultSet.getBigDecimal("seater_fare"));

        schedule.setStatus(
                resultSet.getString("status"));

        return schedule;
    }
 // ==========================================
 // STEP 26 - ADMIN SCHEDULE MANAGEMENT
 // ==========================================

 // Check whether a schedule has ANY booking history.
 // Even cancelled bookings are protected.

 public boolean hasBookingHistory(int scheduleId)
         throws SQLException {

     String sql = """
             SELECT 1
             FROM booking
             WHERE schedule_id = ?
             LIMIT 1
             """;

     try (Connection connection = DBConnection.getConnection();
          PreparedStatement statement =
                  connection.prepareStatement(sql)) {

         statement.setInt(1, scheduleId);

         try (ResultSet resultSet = statement.executeQuery()) {
             return resultSet.next();
         }
     }
 }


 // Check whether a bus already has a schedule
 // for the same date and departure time.

 public boolean hasDuplicateSchedule(
         int busId,
         java.time.LocalDate travelDate,
         java.time.LocalTime departureTime,
         int excludeScheduleId) throws SQLException {

     String sql = """
             SELECT 1
             FROM bus_schedule
             WHERE bus_id = ?
               AND travel_date = ?
               AND departure_time = ?
               AND schedule_id <> ?
             LIMIT 1
             """;

     try (Connection connection = DBConnection.getConnection();
          PreparedStatement statement =
                  connection.prepareStatement(sql)) {

         statement.setInt(1, busId);

         statement.setDate(
                 2, Date.valueOf(travelDate));

         statement.setTime(
                 3, Time.valueOf(departureTime));

         statement.setInt(4, excludeScheduleId);

         try (ResultSet resultSet = statement.executeQuery()) {
             return resultSet.next();
         }
     }
 }


 // Validate bus, route and seat configuration.

 public boolean isBusReadyForScheduling(int busId)
         throws SQLException {

     String sql = """
             SELECT 1
             FROM bus b
             WHERE b.bus_id = ?
               AND b.status = 'ACTIVE'
               AND b.total_seats = (
                   SELECT COUNT(*)
                   FROM seat s
                   WHERE s.bus_id = b.bus_id
                     AND s.status = 'ACTIVE'
               )
             """;

     try (Connection connection = DBConnection.getConnection();
          PreparedStatement statement =
                  connection.prepareStatement(sql)) {

         statement.setInt(1, busId);

         try (ResultSet resultSet = statement.executeQuery()) {
             return resultSet.next();
         }
     }
 }


 public boolean isRouteActive(int routeId)
         throws SQLException {

     String sql = """
             SELECT 1
             FROM route
             WHERE route_id = ?
               AND status = 'ACTIVE'
             """;

     try (Connection connection = DBConnection.getConnection();
          PreparedStatement statement =
                  connection.prepareStatement(sql)) {

         statement.setInt(1, routeId);

         try (ResultSet resultSet = statement.executeQuery()) {
             return resultSet.next();
         }
     }
 }


 // Update schedule details only when no booking exists.
 // All existing fare categories are preserved.

 public boolean updateAdminSchedule(BusSchedule schedule)
         throws SQLException {

     String sql = """
             UPDATE bus_schedule bs
             SET bs.bus_id = ?,
                 bs.route_id = ?,
                 bs.travel_date = ?,
                 bs.departure_time = ?,
                 bs.arrival_time = ?,
                 bs.fare = ?,
                 bs.upper_deck_fare = ?,
                 bs.lower_deck_fare = ?,
                 bs.double_upper_fare = ?,
                 bs.double_lower_fare = ?,
                 bs.single_upper_fare = ?,
                 bs.single_lower_fare = ?,
                 bs.seater_fare = ?
             WHERE bs.schedule_id = ?
               AND bs.status = 'SCHEDULED'
               AND NOT EXISTS (
                   SELECT 1
                   FROM booking b
                   WHERE b.schedule_id = bs.schedule_id
               )
             """;

     try (Connection connection = DBConnection.getConnection();
          PreparedStatement statement =
                  connection.prepareStatement(sql)) {

         statement.setInt(1, schedule.getBusId());
         statement.setInt(2, schedule.getRouteId());

         statement.setDate(
                 3, Date.valueOf(schedule.getTravelDate()));

         statement.setTime(
                 4, Time.valueOf(schedule.getDepartureTime()));

         statement.setTime(
                 5, Time.valueOf(schedule.getArrivalTime()));

         statement.setBigDecimal(6, schedule.getFare());

         statement.setBigDecimal(
                 7, schedule.getUpperDeckFare());

         statement.setBigDecimal(
                 8, schedule.getLowerDeckFare());

         statement.setBigDecimal(
                 9, schedule.getDoubleUpperFare());

         statement.setBigDecimal(
                 10, schedule.getDoubleLowerFare());

         statement.setBigDecimal(
                 11, schedule.getSingleUpperFare());

         statement.setBigDecimal(
                 12, schedule.getSingleLowerFare());

         statement.setBigDecimal(
                 13, schedule.getSeaterFare());

         statement.setInt(14, schedule.getScheduleId());

         return statement.executeUpdate() > 0;
     }
 }


 // Administrative cancellation.
 // Does NOT cancel passenger bookings or trigger refunds.

 public boolean cancelAdminSchedule(int scheduleId)
         throws SQLException {

     String sql = """
             UPDATE bus_schedule bs
             SET bs.status = 'CANCELLED'
             WHERE bs.schedule_id = ?
               AND bs.status = 'SCHEDULED'
               AND NOT EXISTS (
                   SELECT 1
                   FROM booking b
                   WHERE b.schedule_id = bs.schedule_id
               )
             """;

     try (Connection connection = DBConnection.getConnection();
          PreparedStatement statement =
                  connection.prepareStatement(sql)) {

         statement.setInt(1, scheduleId);

         return statement.executeUpdate() > 0;
     }
 }
     
  // ==========================================
  // STEP 26B - SAFE ADMIN SCHEDULE CREATION
  // ==========================================

  public boolean addAdminSchedule(BusSchedule schedule)
          throws SQLException {

      String lockBusSql = """
              SELECT bus_id
              FROM bus
              WHERE bus_id = ?
              FOR UPDATE
              """;

      String duplicateSql = """
              SELECT 1
              FROM bus_schedule
              WHERE bus_id = ?
                AND travel_date = ?
                AND departure_time = ?
              LIMIT 1
              """;

      String insertSql = """
              INSERT INTO bus_schedule
              (
                  bus_id,
                  route_id,
                  travel_date,
                  departure_time,
                  arrival_time,
                  fare,
                  upper_deck_fare,
                  lower_deck_fare,
                  double_upper_fare,
                  double_lower_fare,
                  single_upper_fare,
                  single_lower_fare,
                  seater_fare,
                  status
              )
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'SCHEDULED')
              """;

      try (Connection connection = DBConnection.getConnection()) {

          connection.setAutoCommit(false);

          try {

              // Serialize admin schedule creation for this bus.

              try (PreparedStatement statement =
                      connection.prepareStatement(lockBusSql)) {

                  statement.setInt(1, schedule.getBusId());

                  try (ResultSet rs = statement.executeQuery()) {

                      if (!rs.next()) {
                          throw new SQLException(
                                  "Selected bus does not exist.");
                      }
                  }
              }

              // Revalidate bus configuration inside transaction.

              String busSql = """
                      SELECT 1
                      FROM bus b
                      WHERE b.bus_id = ?
                        AND b.status = 'ACTIVE'
                        AND b.total_seats = (
                            SELECT COUNT(*)
                            FROM seat s
                            WHERE s.bus_id = b.bus_id
                              AND s.status = 'ACTIVE'
                        )
                      """;

              try (PreparedStatement statement =
                      connection.prepareStatement(busSql)) {

                  statement.setInt(1, schedule.getBusId());

                  try (ResultSet rs = statement.executeQuery()) {

                      if (!rs.next()) {
                          throw new IllegalArgumentException(
                                  "Bus is inactive or its seat layout is incomplete.");
                      }
                  }
              }

              try (PreparedStatement statement =
                      connection.prepareStatement(
                              """
                              SELECT 1
                              FROM route
                              WHERE route_id = ?
                                AND status = 'ACTIVE'
                              """)) {

                  statement.setInt(1, schedule.getRouteId());

                  try (ResultSet rs = statement.executeQuery()) {

                      if (!rs.next()) {
                          throw new IllegalArgumentException(
                                  "Selected route is inactive or unavailable.");
                      }
                  }
              }

              // Check duplicates while holding the bus lock.

              try (PreparedStatement statement =
                      connection.prepareStatement(duplicateSql)) {

                  statement.setInt(1, schedule.getBusId());

                  statement.setDate(
                          2,
                          Date.valueOf(schedule.getTravelDate()));

                  statement.setTime(
                          3,
                          Time.valueOf(schedule.getDepartureTime()));

                  try (ResultSet rs = statement.executeQuery()) {

                      if (rs.next()) {
                          throw new IllegalArgumentException(
                                  "This bus already has a schedule "
                                  + "for the selected date and departure time.");
                      }
                  }
              }

              int affected;

              try (PreparedStatement statement =
                      connection.prepareStatement(insertSql)) {

                  statement.setInt(1, schedule.getBusId());
                  statement.setInt(2, schedule.getRouteId());

                  statement.setDate(
                          3, Date.valueOf(schedule.getTravelDate()));

                  statement.setTime(
                          4, Time.valueOf(schedule.getDepartureTime()));

                  statement.setTime(
                          5, Time.valueOf(schedule.getArrivalTime()));

                  statement.setBigDecimal(6, schedule.getFare());

                  statement.setBigDecimal(
                          7, schedule.getUpperDeckFare());

                  statement.setBigDecimal(
                          8, schedule.getLowerDeckFare());

                  statement.setBigDecimal(
                          9, schedule.getDoubleUpperFare());

                  statement.setBigDecimal(
                          10, schedule.getDoubleLowerFare());

                  statement.setBigDecimal(
                          11, schedule.getSingleUpperFare());

                  statement.setBigDecimal(
                          12, schedule.getSingleLowerFare());

                  statement.setBigDecimal(
                          13, schedule.getSeaterFare());

                  affected = statement.executeUpdate();
              }

              connection.commit();

              return affected == 1;

          } catch (SQLException | RuntimeException e) {

              connection.rollback();
              throw e;

          } finally {

              connection.setAutoCommit(true);
          }
      }
  
 }
  
//==========================================
//STEP 26B - SAFE ADMIN SCHEDULE EDITING
//==========================================

public boolean updateAdminScheduleSafely(BusSchedule schedule)
       throws SQLException {

   try (Connection connection = DBConnection.getConnection()) {

       connection.setAutoCommit(false);

       try {

           // Lock the selected bus first.

           try (PreparedStatement statement =
                   connection.prepareStatement(
                           "SELECT bus_id FROM bus WHERE bus_id = ? FOR UPDATE")) {

               statement.setInt(1, schedule.getBusId());

               try (ResultSet rs = statement.executeQuery()) {

                   if (!rs.next()) {
                       throw new IllegalArgumentException(
                               "Selected bus does not exist.");
                   }
               }
           }

           // Lock the schedule being edited.

           try (PreparedStatement statement =
                   connection.prepareStatement(
                           """
                           SELECT schedule_id
                           FROM bus_schedule
                           WHERE schedule_id = ?
                             AND status = 'SCHEDULED'
                           FOR UPDATE
                           """)) {

               statement.setInt(1, schedule.getScheduleId());

               try (ResultSet rs = statement.executeQuery()) {

                   if (!rs.next()) {
                       throw new IllegalArgumentException(
                               "Schedule is unavailable for editing.");
                   }
               }
           }

           // Protect all historical passenger records.

           try (PreparedStatement statement =
                   connection.prepareStatement(
                           """
                           SELECT 1
                           FROM booking
                           WHERE schedule_id = ?
                           LIMIT 1
                           """)) {

               statement.setInt(1, schedule.getScheduleId());

               try (ResultSet rs = statement.executeQuery()) {

                   if (rs.next()) {
                       throw new IllegalArgumentException(
                               "Schedule has booking history and cannot be edited.");
                   }
               }
           }

           // Check duplicates.

           try (PreparedStatement statement =
                   connection.prepareStatement(
                           """
                           SELECT 1
                           FROM bus_schedule
                           WHERE bus_id = ?
                             AND travel_date = ?
                             AND departure_time = ?
                             AND schedule_id <> ?
                           LIMIT 1
                           """)) {

               statement.setInt(1, schedule.getBusId());

               statement.setDate(
                       2, Date.valueOf(schedule.getTravelDate()));

               statement.setTime(
                       3, Time.valueOf(schedule.getDepartureTime()));

               statement.setInt(4, schedule.getScheduleId());

               try (ResultSet rs = statement.executeQuery()) {

                   if (rs.next()) {
                       throw new IllegalArgumentException(
                               "Duplicate bus schedule detected.");
                   }
               }
           }

           // Revalidate selected bus and route.

           try (PreparedStatement statement =
                   connection.prepareStatement(
                           """
                           SELECT 1
                           FROM bus b
                           WHERE b.bus_id = ?
                             AND b.status = 'ACTIVE'
                             AND b.total_seats = (
                                 SELECT COUNT(*)
                                 FROM seat s
                                 WHERE s.bus_id = b.bus_id
                                   AND s.status = 'ACTIVE'
                             )
                           """)) {

               statement.setInt(1, schedule.getBusId());

               try (ResultSet rs = statement.executeQuery()) {

                   if (!rs.next()) {
                       throw new IllegalArgumentException(
                               "Selected bus is not ready for scheduling.");
                   }
               }
           }

           try (PreparedStatement statement =
                   connection.prepareStatement(
                           """
                           SELECT 1
                           FROM route
                           WHERE route_id = ?
                             AND status = 'ACTIVE'
                           """)) {

               statement.setInt(1, schedule.getRouteId());

               try (ResultSet rs = statement.executeQuery()) {

                   if (!rs.next()) {
                       throw new IllegalArgumentException(
                               "Selected route is inactive.");
                   }
               }
           }

           String sql = """
                   UPDATE bus_schedule bs
                   SET bs.bus_id = ?,
                       bs.route_id = ?,
                       bs.travel_date = ?,
                       bs.departure_time = ?,
                       bs.arrival_time = ?,
                       bs.fare = ?,
                       bs.upper_deck_fare = ?,
                       bs.lower_deck_fare = ?,
                       bs.double_upper_fare = ?,
                       bs.double_lower_fare = ?,
                       bs.single_upper_fare = ?,
                       bs.single_lower_fare = ?,
                       bs.seater_fare = ?
                   WHERE bs.schedule_id = ?
                     AND bs.status = 'SCHEDULED'
                     AND NOT EXISTS (
                         SELECT 1
                         FROM booking b
                         WHERE b.schedule_id = bs.schedule_id
                     )
                   """;

           int affected;

           try (PreparedStatement statement =
                   connection.prepareStatement(sql)) {

               statement.setInt(1, schedule.getBusId());
               statement.setInt(2, schedule.getRouteId());

               statement.setDate(
                       3, Date.valueOf(schedule.getTravelDate()));

               statement.setTime(
                       4, Time.valueOf(schedule.getDepartureTime()));

               statement.setTime(
                       5, Time.valueOf(schedule.getArrivalTime()));

               statement.setBigDecimal(6, schedule.getFare());

               statement.setBigDecimal(
                       7, schedule.getUpperDeckFare());

               statement.setBigDecimal(
                       8, schedule.getLowerDeckFare());

               statement.setBigDecimal(
                       9, schedule.getDoubleUpperFare());

               statement.setBigDecimal(
                       10, schedule.getDoubleLowerFare());

               statement.setBigDecimal(
                       11, schedule.getSingleUpperFare());

               statement.setBigDecimal(
                       12, schedule.getSingleLowerFare());

               statement.setBigDecimal(
                       13, schedule.getSeaterFare());

               statement.setInt(14, schedule.getScheduleId());

               affected = statement.executeUpdate();
           }

           connection.commit();

           return affected == 1;

       } catch (SQLException | RuntimeException e) {

           connection.rollback();
           throw e;

       } finally {

           connection.setAutoCommit(true);
       }
   }
}
}
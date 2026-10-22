package com.tnbus.thread;

public class SeatBookingTask implements Runnable {

    private final SeatBookingManager bookingManager;
    private final int seatId;
    private final long userId;

    public SeatBookingTask(
            SeatBookingManager bookingManager,
            int seatId,
            long userId) {

        this.bookingManager = bookingManager;
        this.seatId = seatId;
        this.userId = userId;
    }

    @Override
    public void run() {

        System.out.println(
                "User " + userId
                + " is trying to book seat " + seatId
        );

        boolean booked =
                bookingManager.bookSeat(seatId, userId);

        if (booked) {
            System.out.println(
                    "Booking completed for User " + userId
            );
        } else {
            System.out.println(
                    "Booking failed for User " + userId
            );
        }
    }
}
package com.tnbus.thread;

import java.util.HashSet;
import java.util.Set;

public class SeatBookingManager {

    private final Set<Integer> bookedSeats;

    public SeatBookingManager() {
        bookedSeats = new HashSet<>();
    }

    public synchronized boolean bookSeat(int seatId, long userId) {

        if (seatId <= 0 || userId <= 0) {
            return false;
        }

        if (bookedSeats.contains(seatId)) {
            System.out.println(
                    "Seat " + seatId + " is already booked by another user."
            );
            return false;
        }

        bookedSeats.add(seatId);

        System.out.println(
                "User " + userId
                + " successfully booked seat " + seatId
        );

        return true;
    }

    public synchronized boolean isSeatBooked(int seatId) {
        return bookedSeats.contains(seatId);
    }

    public synchronized int getBookedSeatCount() {
        return bookedSeats.size();
    }
}
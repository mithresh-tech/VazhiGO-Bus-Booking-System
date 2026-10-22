package com.tnbus.model;

public class BookingPassenger {

    private long passengerId;
    private long bookingId;
    private int seatId;
    private String passengerName;
    private int age;
    private String gender;
    private String passengerPhone;

    public BookingPassenger() {
    }

    public BookingPassenger(long passengerId, long bookingId, int seatId,
                            String passengerName, int age,
                            String gender, String passengerPhone) {
        this.passengerId = passengerId;
        this.bookingId = bookingId;
        this.seatId = seatId;
        this.passengerName = passengerName;
        this.age = age;
        this.gender = gender;
        this.passengerPhone = passengerPhone;
    }

    public long getPassengerId() {
        return passengerId;
    }

    public void setPassengerId(long passengerId) {
        this.passengerId = passengerId;
    }

    public long getBookingId() {
        return bookingId;
    }

    public void setBookingId(long bookingId) {
        this.bookingId = bookingId;
    }

    public int getSeatId() {
        return seatId;
    }

    public void setSeatId(int seatId) {
        this.seatId = seatId;
    }

    public String getPassengerName() {
        return passengerName;
    }

    public void setPassengerName(String passengerName) {
        this.passengerName = passengerName;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getPassengerPhone() {
        return passengerPhone;
    }

    public void setPassengerPhone(String passengerPhone) {
        this.passengerPhone = passengerPhone;
    }
}
package com.tnbus.exception;

public class SeatNotAvailableException extends Exception {

    private static final long serialVersionUID = 1L;

    public SeatNotAvailableException(String message) {
        super(message);
    }
}
package com.tnbus.exception;

public class BusNotFoundException extends Exception {

    private static final long serialVersionUID = 1L;

    public BusNotFoundException(String message) {
        super(message);
    }
}
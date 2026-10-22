package com.tnbus.util;

import java.util.regex.Pattern;

public final class ValidationUtil {

    private ValidationUtil() {
        // Utility class
    }

    public static boolean isNotEmpty(String value) {
        return value != null && !value.trim().isEmpty();
    }

    public static boolean isValidName(String name) {

        if (!isNotEmpty(name)) {
            return false;
        }

        return Pattern.matches(
                "^[A-Za-z ]{2,100}$",
                name.trim()
        );
    }

    public static boolean isValidEmail(String email) {

        if (!isNotEmpty(email)) {
            return false;
        }

        return Pattern.matches(
                "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$",
                email.trim()
        );
    }

    public static boolean isValidPhone(String phone) {

        if (!isNotEmpty(phone)) {
            return false;
        }

        return Pattern.matches(
                "^[0-9]{10,15}$",
                phone.trim()
        );
    }

    public static boolean isValidPassword(String password) {

        if (!isNotEmpty(password)) {
            return false;
        }

        return password.length() >= 6;
    }

    public static boolean isValidId(long id) {
        return id > 0;
    }

    public static boolean isValidId(int id) {
        return id > 0;
    }

    public static boolean isValidAge(int age) {
        return age > 0 && age <= 120;
    }
}
package com.tnbus.service;

import java.sql.SQLException;
import java.util.List;

import com.tnbus.dao.UserDAO;
import com.tnbus.exception.InvalidUserException;
import com.tnbus.model.User;
import com.tnbus.util.ValidationUtil;

public class UserService {

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    public boolean registerUser(User user)
            throws SQLException, InvalidUserException {

        if (user == null) {
            throw new InvalidUserException(
                    "User details cannot be null.");
        }

        if (!ValidationUtil.isValidName(user.getFullName())) {
            throw new InvalidUserException(
                    "Invalid name.");
        }

        if (!ValidationUtil.isValidEmail(user.getEmail())) {
            throw new InvalidUserException(
                    "Invalid email address.");
        }

        if (!ValidationUtil.isValidPhone(user.getPhone())) {
            throw new InvalidUserException(
                    "Invalid phone number.");
        }

        if (!ValidationUtil.isValidPassword(user.getPassword())) {
            throw new InvalidUserException(
                    "Password must contain at least 6 characters.");
        }

        User existingUser =
                userDAO.getUserByEmail(user.getEmail());

        if (existingUser != null) {
            throw new InvalidUserException(
                    "An account already exists with this email.");
        }

        if (user.getStatus() == null
                || user.getStatus().isBlank()) {

            user.setStatus("ACTIVE");
        }

        return userDAO.registerUser(user);
    }

    public User loginUser(String email, String password)
            throws SQLException, InvalidUserException {

        if (!ValidationUtil.isValidEmail(email)) {
            throw new InvalidUserException(
                    "Invalid email address.");
        }

        if (!ValidationUtil.isNotEmpty(password)) {
            throw new InvalidUserException(
                    "Password cannot be empty.");
        }

        User user =
                userDAO.loginUser(email, password);

        if (user == null) {
            throw new InvalidUserException(
                    "Invalid email or password.");
        }

        return user;
    }

    public User getUserById(long userId)
            throws SQLException, InvalidUserException {

        if (userId <= 0) {
            throw new InvalidUserException(
                    "Invalid user ID.");
        }

        User user =
                userDAO.getUserById(userId);

        if (user == null) {
            throw new InvalidUserException(
                    "User not found.");
        }

        return user;
    }

    public List<User> getAllUsers() throws SQLException {

        return userDAO.getAllUsers();
    }

    public boolean updateUser(User user)
            throws SQLException, InvalidUserException {

        if (user == null || user.getUserId() <= 0) {
            throw new InvalidUserException(
                    "Invalid user details.");
        }

        if (!ValidationUtil.isValidName(user.getFullName())) {
            throw new InvalidUserException(
                    "Invalid name.");
        }

        if (!ValidationUtil.isValidPhone(user.getPhone())) {
            throw new InvalidUserException(
                    "Invalid phone number.");
        }

        return userDAO.updateUser(user);
    }
}
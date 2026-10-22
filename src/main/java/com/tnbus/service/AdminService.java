package com.tnbus.service;

import com.tnbus.dao.AdminDAO;
import com.tnbus.exception.InvalidUserException;
import com.tnbus.model.Admin;
import com.tnbus.util.ValidationUtil;

import java.sql.SQLException;
import java.util.List;

public class AdminService {

    private final AdminDAO adminDAO;

    public AdminService() {
        this.adminDAO = new AdminDAO();
    }

    public Admin loginAdmin(String email, String password)
            throws SQLException, InvalidUserException {

        if (!ValidationUtil.isValidEmail(email)) {
            throw new InvalidUserException("Invalid admin email.");
        }

        if (!ValidationUtil.isNotEmpty(password)) {
            throw new InvalidUserException("Password cannot be empty.");
        }

        Admin admin = adminDAO.loginAdmin(email, password);

        if (admin == null) {
            throw new InvalidUserException(
                    "Invalid admin email or password.");
        }

        return admin;
    }

    public Admin getAdminById(long adminId)
            throws SQLException, InvalidUserException {

        if (adminId <= 0) {
            throw new InvalidUserException("Invalid admin ID.");
        }

        Admin admin = adminDAO.getAdminById(adminId);

        if (admin == null) {
            throw new InvalidUserException("Admin not found.");
        }

        return admin;
    }

    public List<Admin> getAllAdmins() throws SQLException {
        return adminDAO.getAllAdmins();
    }
}
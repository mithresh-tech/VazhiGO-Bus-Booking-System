package com.tnbus.model;

public class Admin {

    private long adminId;
    private String adminName;
    private String email;
    private String password;
    private String status;

    public Admin() {
    }

    public Admin(long adminId, String adminName, String email,
                 String password, String status) {
        this.adminId = adminId;
        this.adminName = adminName;
        this.email = email;
        this.password = password;
        this.status = status;
    }

    public long getAdminId() {
        return adminId;
    }

    public void setAdminId(long adminId) {
        this.adminId = adminId;
    }

    public String getAdminName() {
        return adminName;
    }

    public void setAdminName(String adminName) {
        this.adminName = adminName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
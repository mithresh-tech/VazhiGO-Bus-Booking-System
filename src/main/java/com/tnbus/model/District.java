package com.tnbus.model;

public class District {

    private int districtId;
    private String districtName;
    private String status;

    public District() {
    }

    public District(int districtId, String districtName, String status) {
        this.districtId = districtId;
        this.districtName = districtName;
        this.status = status;
    }

    public int getDistrictId() {
        return districtId;
    }

    public void setDistrictId(int districtId) {
        this.districtId = districtId;
    }

    public String getDistrictName() {
        return districtName;
    }

    public void setDistrictName(String districtName) {
        this.districtName = districtName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
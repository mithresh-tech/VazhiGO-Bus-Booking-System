package com.tnbus.model;

public class City {

    private int cityId;
    private int districtId;
    private String cityName;
    private String status;

    public City() {
    }

    public City(int cityId, int districtId, String cityName, String status) {
        this.cityId = cityId;
        this.districtId = districtId;
        this.cityName = cityName;
        this.status = status;
    }

    public int getCityId() {
        return cityId;
    }

    public void setCityId(int cityId) {
        this.cityId = cityId;
    }

    public int getDistrictId() {
        return districtId;
    }

    public void setDistrictId(int districtId) {
        this.districtId = districtId;
    }

    public String getCityName() {
        return cityName;
    }

    public void setCityName(String cityName) {
        this.cityName = cityName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
package com.tnbus.model;

public class BusAmenity {

    private boolean wifi;
    private boolean charging;
    private boolean food;
    private boolean restroom;
    private boolean blanket;
    private boolean waterBottle;

    public BusAmenity() {
    }

    public BusAmenity(
            boolean wifi,
            boolean charging,
            boolean food,
            boolean restroom,
            boolean blanket,
            boolean waterBottle) {

        this.wifi = wifi;
        this.charging = charging;
        this.food = food;
        this.restroom = restroom;
        this.blanket = blanket;
        this.waterBottle = waterBottle;
    }

    public boolean isWifi() {
        return wifi;
    }

    public void setWifi(boolean wifi) {
        this.wifi = wifi;
    }

    public boolean isCharging() {
        return charging;
    }

    public void setCharging(boolean charging) {
        this.charging = charging;
    }

    public boolean isFood() {
        return food;
    }

    public void setFood(boolean food) {
        this.food = food;
    }

    public boolean isRestroom() {
        return restroom;
    }

    public void setRestroom(boolean restroom) {
        this.restroom = restroom;
    }

    public boolean isBlanket() {
        return blanket;
    }

    public void setBlanket(boolean blanket) {
        this.blanket = blanket;
    }

    public boolean isWaterBottle() {
        return waterBottle;
    }

    public void setWaterBottle(boolean waterBottle) {
        this.waterBottle = waterBottle;
    }
}
package com.tnbus.model;

import java.math.BigDecimal;

public class Route {

    private int routeId;
    private int sourceCityId;
    private int destinationCityId;
    private BigDecimal distanceKm;
    private String status;

    public Route() {
    }

    public Route(int routeId, int sourceCityId, int destinationCityId,
                 BigDecimal distanceKm, String status) {
        this.routeId = routeId;
        this.sourceCityId = sourceCityId;
        this.destinationCityId = destinationCityId;
        this.distanceKm = distanceKm;
        this.status = status;
    }

    public int getRouteId() {
        return routeId;
    }

    public void setRouteId(int routeId) {
        this.routeId = routeId;
    }

    public int getSourceCityId() {
        return sourceCityId;
    }

    public void setSourceCityId(int sourceCityId) {
        this.sourceCityId = sourceCityId;
    }

    public int getDestinationCityId() {
        return destinationCityId;
    }

    public void setDestinationCityId(int destinationCityId) {
        this.destinationCityId = destinationCityId;
    }

    public BigDecimal getDistanceKm() {
        return distanceKm;
    }

    public void setDistanceKm(BigDecimal distanceKm) {
        this.distanceKm = distanceKm;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
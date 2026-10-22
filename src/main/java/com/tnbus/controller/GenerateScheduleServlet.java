package com.tnbus.controller;

import com.tnbus.service.ScheduleGeneratorService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/generateSchedules")
public class GenerateScheduleServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private ScheduleGeneratorService scheduleGeneratorService;

    @Override
    public void init() {

        scheduleGeneratorService =
                new ScheduleGeneratorService();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

    	try {

    	    LocalDate startDate =
    	            LocalDate.of(2026, 10, 28);

    	    LocalDate endDate =
    	            LocalDate.of(2026, 11, 2);

    	    int generatedCount =
    	            scheduleGeneratorService
    	                    .generateSchedules(
    	                            startDate,
    	                            endDate);

    	    response.setContentType(
    	            "text/html;charset=UTF-8");

    	    response.getWriter().println(
    	            "<h2>Schedule Generation Completed</h2>");

    	    response.getWriter().println(
    	            "<p>Generated schedules: "
    	            + generatedCount
    	            + "</p>");

    	} catch (Exception e) {

    	    e.printStackTrace();

    	    response.setContentType(
    	            "text/html;charset=UTF-8");

    	    response.getWriter().println(
    	            "<h2>Schedule Generation Failed</h2>");

    	    response.getWriter().println(
    	            "<p>Error: "
    	            + e.getMessage()
    	            + "</p>");
    	}
    }
}
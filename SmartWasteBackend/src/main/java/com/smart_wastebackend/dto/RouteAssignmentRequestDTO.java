package com.smart_wastebackend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RouteAssignmentRequestDTO {
    @NotBlank(message = "Route ID is required")
    private String routeId;

    @NotBlank(message = "Collector ID is required")
    private String collectorId;
}
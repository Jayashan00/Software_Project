package com.smart_wastebackend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TruckAssignCollectorRequestDTO {

    @NotBlank(message = "Truck ID is required")
    private String truckId;

    @NotBlank(message = "Collector ID is required")
    private String collectorId;
}
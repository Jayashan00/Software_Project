package com.smart_wastebackend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.validation.constraints.NotBlank;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateMaintenanceRequestDTO {
    @NotBlank(message = "Bin ID is required")
    private String binId;

    @NotBlank(message = "Request type is required")
    private String requestType;

    @NotBlank(message = "Description is required")
    private String description;

    // Default to MEDIUM if null
    private String priority = "MEDIUM";

    private String notes;
}
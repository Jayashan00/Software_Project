package com.smart_wastebackend.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AddTruckRequestDTO {
    @NotBlank(message = "Registration number must not be blank")
    private String registrationNumber;

    // --- THIS IS THE FIX ---
    @NotNull(message = "Capacity must not be null")
    @Min(value = 1, message = "Capacity must be at least 1")
    private long capacity;
    // --- END OF FIX ---
}
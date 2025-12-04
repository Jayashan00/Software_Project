package com.smart_wastebackend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

@Data
public class CreateRouteRequestDTO {
    @NotBlank(message = "Route name is required")
    private String name;

    @NotEmpty(message = "At least one bin stop is required")
    private List<String> binIds; // A list of Bin IDs for the stops
}
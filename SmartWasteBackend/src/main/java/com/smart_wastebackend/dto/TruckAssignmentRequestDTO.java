package com.smart_wastebackend.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TruckAssignmentRequestDTO {
    @NotNull
    private String registrationNumber;
}

package com.smart_wastebackend.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ProfileUpdateRequestDTO {
    @NotBlank(message = "Name cannot be blank")
    private String name;
}

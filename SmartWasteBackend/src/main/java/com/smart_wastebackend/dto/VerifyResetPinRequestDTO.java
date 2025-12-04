package com.smart_wastebackend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class VerifyResetPinRequestDTO {
    private String sessionToken;

    @NotBlank(message = "PIN is required")
    @Size(min = 6, max = 6, message = "PIN must be 6 digits")
    private String pin;

    @NotBlank(message = "Email is required")
    private String email;
}

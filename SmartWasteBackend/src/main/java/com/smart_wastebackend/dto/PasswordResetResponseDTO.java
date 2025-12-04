package com.smart_wastebackend.dto;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PasswordResetResponseDTO {
    private String sessionToken;
    private String verifiedToken;
    private String email;
    private Long expiresIn; // in milliseconds
}

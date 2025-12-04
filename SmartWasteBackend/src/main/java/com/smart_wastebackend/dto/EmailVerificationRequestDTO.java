package com.smart_wastebackend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

// import java.util.UUID; // REMOVED

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class EmailVerificationRequestDTO {
    private String userId; // CHANGED: UUID to String
}
package com.smart_wastebackend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
// import java.util.UUID; // REMOVED

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MaintenanceRequestDTO {

    private String id; // CHANGED: UUID to String
    private String binId;
    private String requesterId; // CHANGED: UUID to String
    private String requesterName;
    private String requestType;
    private String description;
    private String priority;
    private String status;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime resolvedAt;

    private String assignedTo; // CHANGED: UUID to String
    private String assignedToName;
    private String notes;
}
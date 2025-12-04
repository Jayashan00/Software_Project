package com.smart_wastebackend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;
// import java.util.UUID; // REMOVED

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDTO {

    private String id; // CHANGED: UUID to String
    private String type;
    private String title;
    private String message;
    private Boolean isRead;
    private String priority;
    private String recipientType;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime readAt;

    private String binId;
    private String maintenanceRequestId; // CHANGED: UUID to String
    private String routeId; // CHANGED: UUID to String
    private Map<String, Object> metadata;
}
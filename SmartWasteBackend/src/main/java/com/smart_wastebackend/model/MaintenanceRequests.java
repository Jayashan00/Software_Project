package com.smart_wastebackend.model;

import com.smart_wastebackend.enums.MaintenanceStatus;
import com.smart_wastebackend.enums.Priority;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;

@Document(collection = "maintenance_requests_v2") // Ensures we use a clean collection
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MaintenanceRequests {

    @Id
    private String id;

    @Field("bin_id")
    private String binId;

    @Field("requester_id")
    private String requesterId;

    @Field("request_type")
    private String requestType;

    @Field("description")
    private String description;

    @Field("priority")
    private Priority priority;

    @Field("status")
    private MaintenanceStatus status;

    @Field("created_at")
    private LocalDateTime createdAt;

    @Field("resolved_at")
    private LocalDateTime resolvedAt;

    @Field("assigned_to")
    private String assignedTo;
    @Field("notes")
    private String notes;
}
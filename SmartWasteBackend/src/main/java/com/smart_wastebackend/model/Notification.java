package com.smart_wastebackend.model;

import com.smart_wastebackend.enums.NotificationType;
import com.smart_wastebackend.enums.Priority;
import com.smart_wastebackend.enums.UserRoleEnum;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;
import java.util.Map;

@Document(collection = "notifications")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Notification {

    @Id
    private String id;

    @Field("notification_type")
    private NotificationType notificationType;

    @Field("title")
    private String title;

    @Field("message")
    private String message;

    @Field("recipient_type")
    private UserRoleEnum recipientType;

    @Field("recipient_id")
    private String recipientId;

    @Field("bin_id")
    private String binId;

    @Field("maintenance_request_id")
    private String maintenanceRequestId;

    @Field("is_read")
    @Builder.Default
    private Boolean isRead = false;

    @Field("priority")
    @Builder.Default
    private Priority priority = Priority.MEDIUM;

    @Field("created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Field("read_at")
    private LocalDateTime readAt;

    @Field("expires_at")
    private LocalDateTime expiresAt;

    @Field("metadata")
    private Map<String, Object> metadata; // Spring Data Mongo handles Maps natively
}
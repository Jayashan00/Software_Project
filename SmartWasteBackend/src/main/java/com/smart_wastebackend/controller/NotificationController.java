package com.smart_wastebackend.controller;


import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.NotificationDTO;
import com.smart_wastebackend.dto.NotificationFilterDTO;
import com.smart_wastebackend.dto.NotificationStatsDTO;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.enums.NotificationType;
import com.smart_wastebackend.enums.UserRoleEnum;
import com.smart_wastebackend.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
// import java.util.UUID; // REMOVED
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<NotificationDTO>>> getNotifications(
            @AuthenticationPrincipal UserTable user) {

        UserRoleEnum userRole = user.getRole();
        List<NotificationDTO> notifications = notificationService
                .getNotificationsForUser(user.getId(), userRole);

        return ResponseEntity.ok(ApiResponse.<List<NotificationDTO>>builder()
                .success(true)
                .message("Notifications retrieved successfully")
                .data(notifications)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

    @GetMapping("/filtered")
    public ResponseEntity<ApiResponse<Page<NotificationDTO>>> getFilteredNotifications(
            @AuthenticationPrincipal UserTable user,
            @ModelAttribute NotificationFilterDTO filter) {

        UserRoleEnum userRole = user.getRole();
        Page<NotificationDTO> notifications = notificationService
                .getNotificationsWithFilters(user.getId(), userRole, filter);

        return ResponseEntity.ok(ApiResponse.<Page<NotificationDTO>>builder()
                .success(true)
                .message("Filtered notifications retrieved successfully")
                .data(notifications)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(@AuthenticationPrincipal UserTable user) {
        UserRoleEnum userRole = user.getRole();
        long unreadCount = notificationService.getUnreadCount(user.getId(), userRole);

        return ResponseEntity.ok(ApiResponse.<Long>builder()
                .success(true)
                .message("Unread count retrieved successfully")
                .data(unreadCount)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<NotificationStatsDTO>> getNotificationStats(
            @AuthenticationPrincipal UserTable user) {

        UserRoleEnum userRole = user.getRole();
        NotificationStatsDTO stats = notificationService.getNotificationStats(user.getId(), userRole);

        return ResponseEntity.ok(ApiResponse.<NotificationStatsDTO>builder()
                .success(true)
                .message("Notification statistics retrieved successfully")
                .data(stats)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

    @PutMapping("/{notificationId}/read")
    public ResponseEntity<ApiResponse<Object>> markAsRead(
            @PathVariable String notificationId, // CHANGED: UUID to String
            @AuthenticationPrincipal UserTable user) {

        notificationService.markAsRead(notificationId, user.getId());

        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Notification marked as read")
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

    @PutMapping("/mark-all-read")
    public ResponseEntity<ApiResponse<Object>> markAllAsRead(@AuthenticationPrincipal UserTable user) {
        UserRoleEnum userRole = user.getRole();
        notificationService.markAllAsRead(user.getId(), userRole);

        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("All notifications marked as read")
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

    @DeleteMapping("/bulk-delete")
    public ResponseEntity<ApiResponse<Object>> deleteNotifications(
            @RequestBody List<String> notificationIds, // CHANGED: List<UUID> to List<String>
            @AuthenticationPrincipal UserTable user) {

        notificationService.deleteNotifications(notificationIds, user.getId());

        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Notifications deleted successfully")
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

    @GetMapping("/types")
    public ResponseEntity<ApiResponse<List<String>>> getNotificationTypes() {
        List<String> types = Arrays.stream(NotificationType.values())
                .map(Enum::name)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.<List<String>>builder()
                .success(true)
                .message("Notification types retrieved successfully")
                .data(types)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }
}
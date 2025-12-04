package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.*;
import com.smart_wastebackend.model.MaintenanceRequest;
import com.smart_wastebackend.model.Notification;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.enums.NotificationType;
import com.smart_wastebackend.enums.Priority;
import com.smart_wastebackend.enums.UserRoleEnum;
import com.smart_wastebackend.repository.MaintenanceRequestRepository;
import com.smart_wastebackend.repository.NotificationRepository;
import com.smart_wastebackend.repository.UserTableRepository;
import com.smart_wastebackend.websocket.NotificationWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserTableRepository userTableRepository;
    private final NotificationWebSocketHandler webSocketHandler;
    private final MongoTemplate mongoTemplate;

    // Create notification for high fill level
    public void createFillLevelNotification(String binId, int fillLevel, String binOwnerId) {
        if (fillLevel >= 90) {
            Map<String, Object> metadata = Map.of(
                    "fill_level", fillLevel,
                    "threshold", 90,
                    "alert_type", "HIGH_FILL_LEVEL"
            );

            List<Notification> existingNotifications = notificationRepository
                    .findByBinIdAndNotificationType(binId, NotificationType.FILL_LEVEL_HIGH);

            boolean hasUnreadHighFillNotification = existingNotifications.stream()
                    .anyMatch(n -> !n.getIsRead() && n.getCreatedAt().isAfter(LocalDateTime.now().minusHours(24)));

            if (!hasUnreadHighFillNotification) {
                Notification binOwnerNotification = createNotification(
                        NotificationType.FILL_LEVEL_HIGH,
                        "Bin Almost Full",
                        String.format("Your bin %s is %d%% full and needs collection", binId, fillLevel),
                        UserRoleEnum.ROLE_BIN_OWNER,
                        binOwnerId,
                        binId,
                        Priority.HIGH,
                        metadata,
                        LocalDateTime.now().plusDays(7)
                );

                notificationRepository.save(binOwnerNotification);
                sendRealTimeNotification(binOwnerId, convertToDTO(binOwnerNotification));

                List<UserTable> admins = userTableRepository.findByRole(UserRoleEnum.ROLE_ADMIN);
                for (UserTable admin : admins) {
                    Notification adminNotification = createNotification(
                            NotificationType.FILL_LEVEL_HIGH,
                            "High Fill Level Alert",
                            String.format("Bin %s has reached %d%% capacity", binId, fillLevel),
                            UserRoleEnum.ROLE_ADMIN,
                            admin.getId(),
                            binId,
                            Priority.HIGH,
                            metadata,
                            LocalDateTime.now().plusDays(7)
                    );

                    notificationRepository.save(adminNotification);
                    sendRealTimeNotification(admin.getId(), convertToDTO(adminNotification));
                }
            }
        }
    }

    // Create maintenance request notification (For Admins)
    public void createMaintenanceRequestNotification(String maintenanceRequestId, String binId,
                                                     String description, String requesterId) {
        List<UserTable> admins = userTableRepository.findByRole(UserRoleEnum.ROLE_ADMIN);

        Map<String, Object> metadata = Map.of(
                "requester_id", requesterId,
                "description", description,
                "request_type", "MAINTENANCE"
        );

        for (UserTable admin : admins) {
            Notification notification = createNotification(
                    NotificationType.MAINTENANCE_REQUEST,
                    "New Maintenance Request",
                    String.format("Maintenance request for bin %s: %s", binId, description),
                    UserRoleEnum.ROLE_ADMIN,
                    admin.getId(),
                    binId,
                    Priority.MEDIUM,
                    metadata,
                    null
            );
            notification.setMaintenanceRequestId(maintenanceRequestId);

            notificationRepository.save(notification);
            sendRealTimeNotification(admin.getId(), convertToDTO(notification));
        }
    }

    // Create collection date notification
    public void createCollectionDateNotification(String binId, String binOwnerId, LocalDate collectionDate) {
        Map<String, Object> metadata = Map.of(
                "collection_date", collectionDate.toString(),
                "notification_type", "COLLECTION_REMINDER"
        );

        Notification notification = createNotification(
                NotificationType.COLLECTION_DATE,
                "Collection Scheduled",
                String.format("Your bin %s is scheduled for collection on %s", binId, collectionDate),
                UserRoleEnum.ROLE_BIN_OWNER,
                binOwnerId,
                binId,
                Priority.MEDIUM,
                metadata,
                collectionDate.atTime(23, 59)
        );

        notificationRepository.save(notification);
        sendRealTimeNotification(binOwnerId, convertToDTO(notification));
    }

    // ✅ This method is triggered when Admin marks request as COMPLETED
    public void createMaintenanceCompletedNotification(String maintenanceRequestId, String binId,
                                                       String requesterId, String resolution) {
        Map<String, Object> metadata = Map.of(
                "resolution", resolution != null ? resolution : "Resolved",
                "completion_status", "RESOLVED"
        );

        Notification notification = createNotification(
                NotificationType.MAINTENANCE_COMPLETED,
                "Maintenance Completed",
                String.format("Maintenance request for bin %s has been completed. Note: %s", binId, resolution),
                UserRoleEnum.ROLE_BIN_OWNER,
                requesterId, // Sends to the Bin Owner
                binId,
                Priority.LOW,
                metadata,
                null
        );
        notification.setMaintenanceRequestId(maintenanceRequestId);

        notificationRepository.save(notification);
        sendRealTimeNotification(requesterId, convertToDTO(notification));
    }

    public Page<NotificationDTO> getNotificationsWithFilters(String userId, UserRoleEnum userRole,
                                                             NotificationFilterDTO filter) {
        Sort sort = Sort.by(Sort.Direction.fromString(filter.getSortDirection()), filter.getSortBy());
        Pageable pageable = PageRequest.of(filter.getPage(), filter.getSize(), sort);

        NotificationType notificationType = null;
        if (filter.getNotificationType() != null) {
            try {
                notificationType = NotificationType.valueOf(filter.getNotificationType());
            } catch (IllegalArgumentException e) {
                log.warn("Invalid notification type: {}", filter.getNotificationType());
            }
        }

        Query query = new Query();
        List<Criteria> criteria = new ArrayList<>();

        criteria.add(Criteria.where("recipientId").is(userId));
        criteria.add(Criteria.where("recipientType").is(userRole));

        if (filter.getIsRead() != null) {
            criteria.add(Criteria.where("isRead").is(filter.getIsRead()));
        }
        if (notificationType != null) {
            criteria.add(Criteria.where("notificationType").is(notificationType));
        }
        if (filter.getPriority() != null) {
            try {
                criteria.add(Criteria.where("priority").is(Priority.valueOf(filter.getPriority())));
            } catch (IllegalArgumentException e) {
                log.warn("Invalid priority value: {}", filter.getPriority());
            }
        }

        query.addCriteria(new Criteria().andOperator(criteria.toArray(new Criteria[0])));

        long totalCount = mongoTemplate.count(query, Notification.class);
        query.with(pageable);
        List<Notification> notifications = mongoTemplate.find(query, Notification.class);

        Page<Notification> notificationPage = new PageImpl<>(notifications, pageable, totalCount);
        return notificationPage.map(this::convertToDTO);
    }

    public List<NotificationDTO> getNotificationsForUser(String userId, UserRoleEnum userRole) {
        List<Notification> notifications = notificationRepository
                .findByRecipientIdAndRecipientTypeOrderByCreatedAtDesc(userId, userRole);

        return notifications.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public void markAsRead(String notificationId, String userId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Notification not found"));

        if (!notification.getRecipientId().equals(userId)) {
            throw new RuntimeException("Unauthorized access to notification");
        }

        if (!notification.getIsRead()) {
            notification.setIsRead(true);
            notification.setReadAt(LocalDateTime.now());
            notificationRepository.save(notification);
        }
    }

    public void markAllAsRead(String userId, UserRoleEnum userRole) {
        List<Notification> unreadNotifications = notificationRepository
                .findByRecipientIdAndRecipientTypeAndIsReadFalse(userId, userRole);

        unreadNotifications.forEach(notification -> {
            notification.setIsRead(true);
            notification.setReadAt(LocalDateTime.now());
        });

        notificationRepository.saveAll(unreadNotifications);
    }

    public long getUnreadCount(String userId, UserRoleEnum userRole) {
        return notificationRepository.countByRecipientIdAndRecipientTypeAndIsReadFalse(userId, userRole);
    }

    public NotificationStatsDTO getNotificationStats(String userId, UserRoleEnum userRole) {
        List<Notification> allNotifications = notificationRepository
                .findByRecipientIdAndRecipientTypeOrderByCreatedAtDesc(userId, userRole);

        long total = allNotifications.size();
        long unread = allNotifications.stream().mapToLong(n -> n.getIsRead() ? 0 : 1).sum();
        long highPriority = allNotifications.stream()
                .mapToLong(n -> n.getPriority() == Priority.HIGH || n.getPriority() == Priority.URGENT ? 1 : 0).sum();

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime weekStart = LocalDate.now().minusDays(7).atStartOfDay();

        long today = allNotifications.stream()
                .mapToLong(n -> n.getCreatedAt().isAfter(todayStart) ? 1 : 0).sum();
        long week = allNotifications.stream()
                .mapToLong(n -> n.getCreatedAt().isAfter(weekStart) ? 1 : 0).sum();

        return NotificationStatsDTO.builder()
                .totalNotifications(total)
                .unreadNotifications(unread)
                .highPriorityNotifications(highPriority)
                .todayNotifications(today)
                .weekNotifications(week)
                .build();
    }

    public void deleteNotifications(List<String> notificationIds, String userId) {
        List<Notification> notifications = notificationRepository.findAllById(notificationIds);

        notifications.forEach(notification -> {
            if (!notification.getRecipientId().equals(userId)) {
                throw new RuntimeException("Unauthorized access to notification");
            }
        });

        notificationRepository.deleteAll(notifications);
    }

    @Scheduled(cron = "0 0 2 * * ?")
    public void cleanupExpiredNotifications() {
        List<Notification> expiredNotifications = notificationRepository
                .findByExpiresAtBeforeAndIsReadFalse(LocalDateTime.now());

        log.info("Cleaning up {} expired notifications", expiredNotifications.size());
        notificationRepository.deleteAll(expiredNotifications);
    }

    private Notification createNotification(NotificationType type, String title, String message,
                                            UserRoleEnum recipientType, String recipientId, String binId,
                                            Priority priority, Map<String, Object> metadata,
                                            LocalDateTime expiresAt) {
        return Notification.builder()
                .notificationType(type)
                .title(title)
                .message(message)
                .recipientType(recipientType)
                .recipientId(recipientId)
                .binId(binId)
                .priority(priority)
                .metadata(metadata)
                .expiresAt(expiresAt)
                .build();
    }

    private NotificationDTO convertToDTO(Notification notification) {
        return NotificationDTO.builder()
                .id(notification.getId())
                .type(notification.getNotificationType().name())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .isRead(notification.getIsRead())
                .priority(notification.getPriority().name())
                .recipientType(notification.getRecipientType().name())
                .createdAt(notification.getCreatedAt())
                .readAt(notification.getReadAt())
                .binId(notification.getBinId())
                .maintenanceRequestId(notification.getMaintenanceRequestId())
                .metadata(notification.getMetadata())
                .build();
    }

    private void sendRealTimeNotification(String userId, NotificationDTO notification) {
        try {
            webSocketHandler.sendNotificationToUser(userId, notification);
        } catch (Exception e) {
            log.error("Failed to send real-time notification to user {}: {}", userId, e.getMessage());
        }
    }
}
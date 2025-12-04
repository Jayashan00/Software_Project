package com.smart_wastebackend.repository;

import com.smart_wastebackend.model.Notification;
import com.smart_wastebackend.enums.NotificationType;
import com.smart_wastebackend.enums.UserRoleEnum;
import org.springframework.data.domain.Page; // Keep this
import org.springframework.data.domain.Pageable; // Keep this
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface NotificationRepository extends MongoRepository<Notification, String> {

    List<Notification> findByRecipientIdAndRecipientTypeOrderByCreatedAtDesc(
            String recipientId, UserRoleEnum recipientType);

    long countByRecipientIdAndRecipientTypeAndIsReadFalse(
            String recipientId, UserRoleEnum recipientType);

    List<Notification> findByRecipientIdAndRecipientTypeAndIsReadFalse(
            String recipientId, UserRoleEnum recipientType);

    List<Notification> findByExpiresAtBeforeAndIsReadFalse(LocalDateTime expiredDate);

    List<Notification> findByBinIdAndNotificationType(String binId, NotificationType notificationType);

    @Query("{'recipientType': ?0, 'createdAt': {'$gte': ?1, '$lte': ?2}}")
    List<Notification> findByRecipientTypeAndDateRange(
            @Param("recipientType") UserRoleEnum recipientType,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    // --- REMOVED THE BROKEN METHOD ---
    // Page<Notification> findNotificationsWithFilters(...)
}
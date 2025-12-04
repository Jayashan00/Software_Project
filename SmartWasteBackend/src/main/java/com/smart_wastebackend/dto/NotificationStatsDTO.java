package com.smart_wastebackend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationStatsDTO {
    private long totalNotifications;
    private long unreadNotifications;
    private long highPriorityNotifications;
    private long todayNotifications;
    private long weekNotifications;
}

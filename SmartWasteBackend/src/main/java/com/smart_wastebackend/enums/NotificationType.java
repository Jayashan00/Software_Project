package com.smart_wastebackend.enums;

public enum NotificationType {
    FILL_LEVEL_HIGH("Fill Level High", "Your bin is 90% full and needs collection"),
    COLLECTION_DATE("Collection Scheduled", "Your bin is scheduled for collection"),
    BIN_COLLECTED("Bin Collected", "Your bin has been successfully collected"),
    MAINTENANCE_REQUEST("Maintenance Request", "New maintenance request received"),
    ROUTE_ASSIGNED("Route Assigned", "New collection route has been assigned"),
    MAINTENANCE_COMPLETED("Maintenance Completed", "Maintenance request has been completed");

    private final String title;
    private final String defaultMessage;

    NotificationType(String title, String defaultMessage) {
        this.title = title;
        this.defaultMessage = defaultMessage;
    }

    public String getTitle() {
        return title;
    }

    public String getDefaultMessage() {
        return defaultMessage;
    }
}
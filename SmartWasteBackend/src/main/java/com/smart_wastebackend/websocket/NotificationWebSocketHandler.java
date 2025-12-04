package com.smart_wastebackend.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smart_wastebackend.dto.NotificationDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationWebSocketHandler implements WebSocketHandler {

    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String userId = getUserIdFromSession(session);
        if (userId != null) {
            sessions.put(userId, session);
            log.info("WebSocket connection established for user: {}", userId);
        }
    }

    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws Exception {
        // Handle incoming messages if needed
        log.debug("Received message: {}", message.getPayload());
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log.error("WebSocket transport error: {}", exception.getMessage());
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus closeStatus) throws Exception {
        String userId = getUserIdFromSession(session);
        if (userId != null) {
            sessions.remove(userId);
            log.info("WebSocket connection closed for user: {}", userId);
        }
    }

    @Override
    public boolean supportsPartialMessages() {
        return false;
    }

    public void sendNotificationToUser(String userId, NotificationDTO notification) {
        WebSocketSession session = sessions.get(userId);
        if (session != null && session.isOpen()) {
            try {
                String message = objectMapper.writeValueAsString(notification);
                session.sendMessage(new TextMessage(message));
                log.debug("Sent notification to user {}: {}", userId, notification.getTitle());
            } catch (IOException e) {
                log.error("Failed to send notification to user {}: {}", userId, e.getMessage());
                sessions.remove(userId); // Remove invalid session
            }
        }
    }

    private String getUserIdFromSession(WebSocketSession session) {
        // Extract user ID from session attributes or query parameters
        Map<String, Object> attributes = session.getAttributes();
        Object userId = attributes.get("userId");

        if (userId == null) {
            // Try to get from query parameters
            String query = session.getUri().getQuery();
            if (query != null && query.contains("userId=")) {
                String[] params = query.split("&");
                for (String param : params) {
                    if (param.startsWith("userId=")) {
                        return param.substring(7);
                    }
                }
            }
        }

        return userId != null ? userId.toString() : null;
    }
}
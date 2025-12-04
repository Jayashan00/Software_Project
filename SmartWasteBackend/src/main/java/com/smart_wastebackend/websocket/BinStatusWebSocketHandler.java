package com.smart_wastebackend.websocket;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class BinStatusWebSocketHandler implements WebSocketHandler {

    private static final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        String username = (String) session.getAttributes().get("username");
        if (username != null) {
            sessions.put(username, session);
            System.out.println("WebSocket connected: " + username);
        }
    }

    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) {
        // No handling needed yet
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        System.out.println("Transport error: " + exception.getMessage());
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus closeStatus) {
        String username = (String) session.getAttributes().get("username");
        if (username != null) {
            sessions.remove(username);
            System.out.println("Disconnected: " + username);
        }
    }

    @Override
    public boolean supportsPartialMessages() {
        return false;
    }

    // Public method to send bin status message to a user
    public void sendStatusToUser(String username, String message) {
        WebSocketSession session = sessions.get(username);
        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new TextMessage(message));
                System.out.println("Sent to " + username + ": " + message);
            } catch (IOException e) {
                System.out.println("Failed to send message to " + username + ": " + e.getMessage());
            }
        } else {
            System.out.println("No open WebSocket session for user: " + username);
        }
    }
}

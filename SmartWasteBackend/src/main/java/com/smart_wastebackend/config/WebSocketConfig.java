package com.smart_wastebackend.config;


import com.smart_wastebackend.websocket.BinStatusWebSocketHandler;
import com.smart_wastebackend.websocket.JwtHandshakeInterceptor;
import com.smart_wastebackend.websocket.NotificationWebSocketHandler;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final BinStatusWebSocketHandler webSocketHandler;
    private final JwtHandshakeInterceptor jwtHandshakeInterceptor;
    private final NotificationWebSocketHandler notificationWebSocketHandler;

    public WebSocketConfig(BinStatusWebSocketHandler webSocketHandler,
                           JwtHandshakeInterceptor jwtHandshakeInterceptor, NotificationWebSocketHandler notificationWebSocketHandler) {
        this.webSocketHandler = webSocketHandler;
        this.jwtHandshakeInterceptor = jwtHandshakeInterceptor;
        this.notificationWebSocketHandler = notificationWebSocketHandler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry
                .addHandler(webSocketHandler, "/ws/bin-status")
                .addInterceptors(jwtHandshakeInterceptor)
                .setAllowedOrigins("*");// In production, specify allowed origins (e.g., "https://yourapp.com")

        registry.addHandler(notificationWebSocketHandler, "/ws/notifications")
                .setAllowedOrigins("*")
                .withSockJS();
    }
}

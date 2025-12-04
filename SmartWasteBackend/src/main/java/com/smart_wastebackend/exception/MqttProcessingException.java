package com.smart_wastebackend.exception;

public class MqttProcessingException extends RuntimeException {
    public MqttProcessingException(String message) {
        super(message);
    }
}

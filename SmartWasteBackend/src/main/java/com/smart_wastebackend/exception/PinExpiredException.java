package com.smart_wastebackend.exception;

public class PinExpiredException extends RuntimeException {
    public PinExpiredException(String message) {
        super(message);
    }
}

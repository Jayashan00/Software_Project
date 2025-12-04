package com.smart_wastebackend.exception;

public class TooSoonException extends RuntimeException {
    public TooSoonException(String message) {
        super(message);
    }
}

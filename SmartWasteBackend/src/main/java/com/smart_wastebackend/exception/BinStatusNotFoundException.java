package com.smart_wastebackend.exception;

public class BinStatusNotFoundException extends RuntimeException {
    public BinStatusNotFoundException(String message) {
        super(message);
    }
}

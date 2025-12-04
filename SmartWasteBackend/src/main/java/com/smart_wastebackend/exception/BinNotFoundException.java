package com.smart_wastebackend.exception;

public class BinNotFoundException extends RuntimeException {
    public BinNotFoundException(String binId) {
        super("Bin with ID " + binId + " not found.");
    }
}

package com.smart_wastebackend.exception;

public class BinAlreadyExistsException extends RuntimeException {
    public BinAlreadyExistsException(String binId) {
        super("Bin with ID " + binId + " already exists.");
    }
}

package com.smart_wastebackend.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smart_wastebackend.dto.BinStatusDTO;
import com.smart_wastebackend.exception.BinNotFoundException;
import com.smart_wastebackend.exception.UserNotFoundException;
import com.smart_wastebackend.model.BinInventory;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.repository.BinInventoryRepository;
import com.smart_wastebackend.repository.UserTableRepository;
import com.smart_wastebackend.websocket.BinStatusWebSocketHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class BinStatusSocketService {
    private final BinStatusWebSocketHandler handler;
    private final ObjectMapper objectMapper;
    private final BinInventoryRepository binInventory;
    private final UserTableRepository userRepository;

    @Autowired
    public BinStatusSocketService(
            BinStatusWebSocketHandler handler,
            ObjectMapper objectMapper,
            BinInventoryRepository binInventory,
            UserTableRepository userRepository) {
        this.handler = handler;
        this.objectMapper = objectMapper;
        this.binInventory = binInventory;
        this.userRepository = userRepository;
    }

    public void sendBinStatusToUser(String binId, BinStatusDTO dto) {
        BinInventory bin = binInventory.findById(binId)
                .orElseThrow(() -> new BinNotFoundException(binId));

        // --- THIS IS THE FIX ---
        // Changed bin.getOwner().getUserId() to bin.getOwnerId()
        UserTable user = userRepository.findById(bin.getOwnerId())
                .orElseThrow(() -> new UserNotFoundException("User not found"));
        // -----------------------

        try {
            String jsonMessage = objectMapper.writeValueAsString(dto);
            handler.sendStatusToUser(user.getUsername(), jsonMessage);
        } catch (JsonProcessingException e) {
            System.out.println("Error converting DTO to JSON: " + e.getMessage());
        }
    }
}
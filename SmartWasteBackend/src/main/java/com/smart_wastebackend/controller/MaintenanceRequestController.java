package com.smart_wastebackend.controller;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.CreateMaintenanceRequestDTO;
import com.smart_wastebackend.dto.MaintenanceRequestDTO;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.enums.MaintenanceStatus;
import com.smart_wastebackend.service.MaintenanceRequestService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/maintenance-requests")
@RequiredArgsConstructor
@Slf4j
public class MaintenanceRequestController {

    private final MaintenanceRequestService maintenanceRequestService;

    // --- CREATE ---
    @PostMapping
    public ResponseEntity<ApiResponse<String>> createMaintenanceRequest(
            @Valid @RequestBody CreateMaintenanceRequestDTO request,
            @AuthenticationPrincipal UserTable user) {

        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.<String>builder().success(false).message("User not authenticated").build());
        }

        try {
            String requestId = maintenanceRequestService.createRequest(request, user.getId());
            return ResponseEntity.ok(ApiResponse.<String>builder()
                    .success(true)
                    .message("Maintenance request created successfully")
                    .data(requestId)
                    .timestamp(LocalDateTime.now().toString())
                    .build());
        } catch (Exception e) {
            log.error("Error creating request: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.<String>builder().success(false).message(e.getMessage()).build());
        }
    }

    // --- READ (All with filters) ---
    @GetMapping
    public ResponseEntity<ApiResponse<Page<MaintenanceRequestDTO>>> getMaintenanceRequests(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String binId,
            @RequestParam(required = false) String requesterId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        try {
            MaintenanceStatus statusEnum = null;
            if (status != null && !status.isEmpty()) {
                try {
                    statusEnum = MaintenanceStatus.valueOf(status.toUpperCase());
                } catch (IllegalArgumentException e) {
                    // Ignore invalid status or return error
                }
            }

            Page<MaintenanceRequestDTO> requests = maintenanceRequestService
                    .getRequestsWithFilters(statusEnum, binId, requesterId, page, size);

            return ResponseEntity.ok(ApiResponse.<Page<MaintenanceRequestDTO>>builder()
                    .success(true)
                    .message("Requests retrieved successfully")
                    .data(requests)
                    .timestamp(LocalDateTime.now().toString())
                    .build());
        } catch (Exception e) {
            log.error("Error fetching requests: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.<Page<MaintenanceRequestDTO>>builder().success(false).message(e.getMessage()).build());
        }
    }

    // --- READ (Single ID) ---
    @GetMapping("/{requestId}")
    public ResponseEntity<ApiResponse<MaintenanceRequestDTO>> getMaintenanceRequest(
            @PathVariable String requestId) {
        try {
            MaintenanceRequestDTO request = maintenanceRequestService.getRequestById(requestId);
            return ResponseEntity.ok(ApiResponse.<MaintenanceRequestDTO>builder()
                    .success(true)
                    .data(request)
                    .build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.<MaintenanceRequestDTO>builder().success(false).message(e.getMessage()).build());
        }
    }

    // --- UPDATE (Full Details) - This fixes your "Update Error" ---
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<MaintenanceRequestDTO>> updateMaintenanceRequest(
            @PathVariable String id,
            @RequestBody CreateMaintenanceRequestDTO requestDTO) {
        try {
            MaintenanceRequestDTO updatedRequest = maintenanceRequestService.updateRequestDetails(id, requestDTO);
            return ResponseEntity.ok(ApiResponse.<MaintenanceRequestDTO>builder()
                    .success(true)
                    .message("Request updated successfully")
                    .data(updatedRequest)
                    .timestamp(LocalDateTime.now().toString())
                    .build());
        } catch (Exception e) {
            log.error("Error updating request: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.<MaintenanceRequestDTO>builder().success(false).message(e.getMessage()).build());
        }
    }

    // --- UPDATE (Status Only) ---
    @PutMapping("/{requestId}/status")
    public ResponseEntity<ApiResponse<Object>> updateRequestStatus(
            @PathVariable String requestId,
            @RequestParam String status,
            @RequestParam(required = false) String assignedTo,
            @RequestParam(required = false) String notes) {
        try {
            MaintenanceStatus statusEnum = MaintenanceStatus.valueOf(status.toUpperCase());
            maintenanceRequestService.updateRequestStatus(requestId, statusEnum, assignedTo, notes);
            return ResponseEntity.ok(ApiResponse.builder()
                    .success(true)
                    .message("Status updated successfully")
                    .timestamp(LocalDateTime.now().toString())
                    .build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.builder().success(false).message(e.getMessage()).build());
        }
    }

    // --- DELETE ---
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteMaintenanceRequest(@PathVariable String id) {
        try {
            maintenanceRequestService.deleteRequest(id);
            return ResponseEntity.ok(ApiResponse.<Void>builder()
                    .success(true)
                    .message("Request deleted successfully")
                    .timestamp(LocalDateTime.now().toString())
                    .build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.<Void>builder().success(false).message(e.getMessage()).build());
        }
    }
}
package com.smart_wastebackend.controller;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.TruckAssignmentRequestDTO;
import com.smart_wastebackend.dto.TruckAssignmentResponseDTO;
import com.smart_wastebackend.model.CollectorProfile; // <-- ADD IMPORT
import com.smart_wastebackend.model.TruckAssignment;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.service.TruckAssignmentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/collector/trucks")
public class TruckAssignmentController {

    private final TruckAssignmentService truckAssignmentService;

    @Autowired
    public TruckAssignmentController(TruckAssignmentService truckAssignmentService) {
        this.truckAssignmentService = truckAssignmentService;
    }

    // --- ADD THIS NEW ENDPOINT ---
    @GetMapping("/available-collectors")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<CollectorProfile>>> getAvailableCollectors() {
        ApiResponse<List<CollectorProfile>> response = truckAssignmentService.getAvailableCollectors();
        return ResponseEntity.ok(response);
    }
    // --- END OF NEW ENDPOINT ---

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<TruckAssignmentResponseDTO>>> getAllAssignedTrucks(){
        ApiResponse<List<TruckAssignmentResponseDTO>> response = truckAssignmentService.getAllTrucksWithCollectors();
        System.out.println(response);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/assign")
    @PreAuthorize("hasRole('COLLECTOR')")
    public ResponseEntity<ApiResponse<TruckAssignment>> assignTruck(@Valid @RequestBody TruckAssignmentRequestDTO request, @AuthenticationPrincipal UserTable user) {
        ApiResponse<TruckAssignment> response = truckAssignmentService.assignTruckToCollector(request.getRegistrationNumber(), user.getId());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/handover")
    @PreAuthorize("hasRole('COLLECTOR')")
    public ResponseEntity<ApiResponse<String>> handOverTruck(@Valid @RequestBody TruckAssignmentRequestDTO request, @AuthenticationPrincipal UserTable user) {
        ApiResponse<String> response = truckAssignmentService.handOverTruck(request.getRegistrationNumber(), user.getId());

        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }

        if ("Truck not found".equals(response.getMessage())) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }
}
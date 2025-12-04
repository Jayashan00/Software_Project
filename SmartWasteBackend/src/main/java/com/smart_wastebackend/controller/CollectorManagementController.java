package com.smart_wastebackend.controller;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.CollectorCreateRequestDTO;
import com.smart_wastebackend.service.CollectorManagementService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

// import java.util.UUID; // REMOVED

@RestController
@RequestMapping("/api/admin/collectors")
@PreAuthorize("hasRole('ADMIN')")
public class CollectorManagementController {

    private final CollectorManagementService collectorService;

    public CollectorManagementController(CollectorManagementService collectorService) {
        this.collectorService = collectorService;
    }

    @PostMapping
    public ApiResponse<String> createCollector(
            @RequestBody @Valid CollectorCreateRequestDTO request) {
        return collectorService.createCollector(request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<String>> deleteCollector(@PathVariable String id) { // CHANGED: UUID to String
        System.out.println("id" + id);
        ApiResponse<String> response = collectorService.deleteCollector(id); // ID is now a String
        return ResponseEntity.ok(response);
    }
}
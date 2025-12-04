package com.smart_wastebackend.controller;

import com.smart_wastebackend.dto.*;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.model.Route;
import com.smart_wastebackend.service.RouteService;
import jakarta.validation.Valid; // <-- ADD IMPORT
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/routes")
public class RouteController {

    private final RouteService routeService;

    @Autowired
    public RouteController(RouteService routeService) {
        this.routeService = routeService;
    }

    // --- (Collector) Get your assigned route ---
    @GetMapping("/assigned")
    @PreAuthorize("hasRole('COLLECTOR')")
    public ResponseEntity<ApiResponse<AssignedRouteResponseDTO>> getAssignedRoute(
            @AuthenticationPrincipal UserTable user
    ) {
        ApiResponse<AssignedRouteResponseDTO> response = routeService.getAssignedRoute(user.getId());
        return ResponseEntity.ok(response);
    }

    // --- (Admin) Get all routes ---
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<Route>>> getAllRoutes() {
        ApiResponse<List<Route>> response = routeService.getAllRoutes();
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    // --- (Admin) Create a new route ---
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Route>> createRoute(
            @Valid @RequestBody CreateRouteRequestDTO request
    ) {
        ApiResponse<Route> response = routeService.createRoute(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // --- (Admin) Update an existing route ---
    @PutMapping("/{routeId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Route>> updateRoute(
            @PathVariable String routeId,
            @Valid @RequestBody CreateRouteRequestDTO request // Reuse DTO
    ) {
        ApiResponse<Route> response = routeService.updateRoute(routeId, request);
        return ResponseEntity.ok(response);
    }

    // --- (Admin) Delete a route ---
    @DeleteMapping("/{routeId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteRoute(
            @PathVariable String routeId
    ) {
        ApiResponse<Void> response = routeService.deleteRoute(routeId);
        return ResponseEntity.ok(response);
    }

    // --- (Admin) Assign a collector to a route ---
    @PostMapping("/assign")
    @PreAuthorize("hasAnyRole('ADMIN')")
    public ResponseEntity<ApiResponse<Route>> assignRouteToCollector(
            @Valid @RequestBody RouteAssignmentRequestDTO request
    ) {
        ApiResponse<Route> response = routeService.assignRouteToCollector(request.getRouteId(), request.getCollectorId());
        return ResponseEntity.ok(response);
    }

    // --- (Collector) Start a route ---
    @PostMapping("/{routeId}/start")
    @PreAuthorize("hasRole('COLLECTOR')")
    public ResponseEntity<ApiResponse<String>> startRoute(
            @AuthenticationPrincipal UserTable user,
            @PathVariable String routeId
    ) {
        ApiResponse<String> response = routeService.startRoute(user.getId(), routeId);
        return ResponseEntity.ok(response);
    }

    // --- (Collector) Mark a bin as collected ---
    @PostMapping("/mark-collected")
    @PreAuthorize("hasRole('COLLECTOR')")
    public ResponseEntity<ApiResponse<String>> markAsCollected(
            @AuthenticationPrincipal UserTable user,
            @RequestBody MarkBinCollectedRequestDTO request
    ) {
        ApiResponse<String> response = routeService.markAsCollected(user.getId(), request);
        return ResponseEntity.ok(response);
    }

    // --- (Collector) Stop a route ---
    @PostMapping("/{routeId}/stop")
    @PreAuthorize("hasRole('COLLECTOR')")
    public ResponseEntity<ApiResponse<String>> stopRoute(
            @AuthenticationPrincipal UserTable user,
            @PathVariable String routeId
    ) {
        ApiResponse<String> response = routeService.stopRoute(user.getId(), routeId);
        return ResponseEntity.ok(response);
    }
}
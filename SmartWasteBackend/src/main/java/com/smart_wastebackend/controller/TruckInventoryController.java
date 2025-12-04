package com.smart_wastebackend.controller;

import com.smart_wastebackend.dto.AddTruckRequestDTO;
import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.ChangeTruckStatusRequestDTO;
import com.smart_wastebackend.dto.TruckAssignCollectorRequestDTO;
import com.smart_wastebackend.enums.TruckStatusEnum;
import com.smart_wastebackend.model.TruckInventory;
import com.smart_wastebackend.service.TruckInventoryService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/admin/trucks")
public class TruckInventoryController {

    private final TruckInventoryService truckService;

    @Autowired
    public TruckInventoryController(TruckInventoryService truckService) {
        this.truckService = truckService;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'COLLECTOR')")
    public ApiResponse<List<TruckInventory>> getTrucks(
            @RequestParam(required = false) TruckStatusEnum status,
            @RequestParam(required = false) Long capacity
    ) {
        return truckService.getTrucksFiltered(status, capacity);
    }

    @PostMapping("/add")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<TruckInventory> addTruck(@Valid @RequestBody AddTruckRequestDTO request) {
        return truckService.addTruck(request.getRegistrationNumber(), request.getCapacity());
    }

    @PutMapping("/{truckId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<TruckInventory> updateTruck(
            @PathVariable String truckId,
            @Valid @RequestBody AddTruckRequestDTO request
    ) {
        return truckService.updateTruck(truckId, request);
    }

    @DeleteMapping("/{truckId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Void> deleteTruck(@PathVariable String truckId) {
        return truckService.deleteTruck(truckId);
    }

    @PutMapping("/{truckId}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<TruckInventory> changeStatus(@PathVariable String truckId,
                                                    @RequestBody ChangeTruckStatusRequestDTO request) {
        return truckService.changeStatus(truckId, request.getStatus());
    }

    @PostMapping("/assign-collector")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<TruckInventory> assignTruckToCollector(
            @Valid @RequestBody TruckAssignCollectorRequestDTO request
    ) {
        return truckService.assignTruckToCollector(request.getTruckId(), request.getCollectorId());
    }

    // ✅ NEW: Get Truck Location for a Bin (Called by Mobile App)
    @GetMapping("/track/bin/{binId}")
    @PreAuthorize("hasAnyRole('ROLE_BIN_OWNER', 'ROLE_ADMIN')")
    public ApiResponse<TruckInventory> getTruckLocationByBin(@PathVariable String binId) {
        try {
            TruckInventory truck = truckService.getTruckForBin(binId);
            return ApiResponse.<TruckInventory>builder()
                    .success(true)
                    .message("Truck location retrieved")
                    .data(truck)
                    .timestamp(LocalDateTime.now().toString())
                    .build();
        } catch (Exception e) {
            return ApiResponse.<TruckInventory>builder()
                    .success(false)
                    .message(e.getMessage())
                    .build();
        }
    }

    // ✅ NEW: Simulate Truck Movement (For Testing)
    @PostMapping("/simulate/{truckId}")
    public void updateLocation(@PathVariable String truckId, @RequestParam Double lat, @RequestParam Double lng) {
        truckService.updateTruckLocation(truckId, lat, lng);
    }
}
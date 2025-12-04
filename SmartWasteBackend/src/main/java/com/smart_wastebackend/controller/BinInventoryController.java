package com.smart_wastebackend.controller;

import com.smart_wastebackend.dto.*;
import com.smart_wastebackend.enums.BinStatusEnum;
import com.smart_wastebackend.model.BinInventory;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.service.BinInventoryService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bins")
public class BinInventoryController {

    private final BinInventoryService binService;

    @Autowired
    public BinInventoryController(BinInventoryService binService) {
        this.binService = binService;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN')")
    public ApiResponse<List<BinInventoryResponseDTO>> getBins(
            @RequestParam(required = false) BinStatusEnum status,
            @RequestParam(required = false) String ownerId
    ) {
        return binService.getBinsFiltered(status, ownerId);
    }

    @GetMapping("/fetch")
    @PreAuthorize("hasRole('BIN_OWNER')")
    public ApiResponse<List<BinInventoryResponseDTO>> fetchBins(@AuthenticationPrincipal UserTable userTable) {
        return binService.fetchUserBins(userTable.getId());
    }

    @PostMapping("/add")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<BinInventory> addBin(@Valid @RequestBody AddBinRequestDTO request) {
        return binService.addBin(request.getBinId());
    }

    // 1. EDIT BIN LOCATION (UPDATE)
    @PutMapping("/{binId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<BinInventory> updateBin(
            @PathVariable String binId,
            @Valid @RequestBody BinLocationDTO request
    ) {
        return binService.updateBinLocation(binId, request);
    }
    // END OF NEW METHOD

    @DeleteMapping("/{binId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Void> deleteBin(@PathVariable String binId) {
        return binService.deleteBin(binId);
    }

    @PutMapping("/{binId}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<BinInventory> changeStatus(@PathVariable String binId,
                                                  @RequestBody ChangeBinStatusRequestDTO request) {
        return binService.changeStatus(binId, request.getStatus());
    }

    // 2. ADMIN-LEVEL ASSIGNMENT
    @PutMapping("/{binId}/assign-owner")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<BinInventory> changeOwner(
            @PathVariable String binId,
            @Valid @RequestBody ChangeOwnerRequestDTO request
    ) {
        return binService.assignBinToOwner(binId, request.getNewOwnerId());
    }
    // END OF NEW METHOD

    // This endpoint is for a BIN_OWNER to claim an AVAILABLE bin
    @PutMapping("/{binId}/assign")
    @PreAuthorize("hasRole('BIN_OWNER')")
    public ApiResponse<BinInventory> assignBinToSelf(@PathVariable String binId, @AuthenticationPrincipal UserTable user) {
        return binService.assignBinToOwner(binId, user.getId());
    }
}
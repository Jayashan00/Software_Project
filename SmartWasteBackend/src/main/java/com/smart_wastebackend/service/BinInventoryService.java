package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.BinInventoryResponseDTO;
import com.smart_wastebackend.dto.BinLocationDTO;
import com.smart_wastebackend.enums.BinStatusEnum;
import com.smart_wastebackend.exception.BinAlreadyExistsException;
import com.smart_wastebackend.exception.BinNotFoundException;
import com.smart_wastebackend.exception.UserNotFoundException;
import com.smart_wastebackend.model.BinInventory;
import com.smart_wastebackend.repository.BinInventoryRepository;
import com.smart_wastebackend.repository.BinOwnerProfileRepository;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class BinInventoryService {

    private final BinInventoryRepository binInventoryRepository;
    private final BinOwnerProfileRepository binOwnerProfileRepository;

    @Autowired
    public BinInventoryService(
            BinInventoryRepository binInventoryRepository,
            BinOwnerProfileRepository binOwnerProfileRepository
    ) {
        this.binInventoryRepository = binInventoryRepository;
        this.binOwnerProfileRepository = binOwnerProfileRepository;
    }

    public ApiResponse<List<BinInventoryResponseDTO>> getBinsFiltered(BinStatusEnum status, String ownerId) {
        List<BinInventory> binInventories;

        if (status != null && ownerId != null) {
            binInventories = binInventoryRepository.findByStatusAndOwnerId(status, ownerId);
        } else if (status != null) {
            binInventories = binInventoryRepository.findByStatus(status);
        } else if (ownerId != null) {
            binInventories = binInventoryRepository.findByOwnerId(ownerId);
        } else {
            binInventories = binInventoryRepository.findAll();
        }

        List<BinInventoryResponseDTO> bins = binInventories.stream()
                .map(bin -> {
                    BinInventoryResponseDTO dto = new BinInventoryResponseDTO();
                    dto.setBinId(bin.getBinId());
                    dto.setStatus(bin.getStatus());
                    dto.setAssignedDate(bin.getAssignedDate());
                    dto.setLatitude(bin.getLatitude());
                    dto.setLongitude(bin.getLongitude());
                    return dto;
                })
                .toList();

        return ApiResponse.<List<BinInventoryResponseDTO>>builder()
                .success(true)
                .message("Bins are fetched successfully")
                .data(bins)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    // FIXED VERSION — Only return ASSIGNED bins
    public ApiResponse<List<BinInventoryResponseDTO>> fetchUserBins(String ownerId) {
        List<BinInventory> binInventories =
                binInventoryRepository.findByOwnerIdAndStatus(ownerId, BinStatusEnum.ASSIGNED);

        List<BinInventoryResponseDTO> bins = binInventories.stream()
                .map(bin -> {
                    BinInventoryResponseDTO dto = new BinInventoryResponseDTO();
                    dto.setBinId(bin.getBinId());
                    dto.setStatus(bin.getStatus());
                    dto.setAssignedDate(bin.getAssignedDate());
                    dto.setLatitude(bin.getLatitude());
                    dto.setLongitude(bin.getLongitude());
                    return dto;
                })
                .toList();

        return ApiResponse.<List<BinInventoryResponseDTO>>builder()
                .success(true)
                .message("Assigned bins fetched successfully")
                .data(bins)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    @Transactional
    public ApiResponse<BinInventory> addBin(String binId) {
        if (binInventoryRepository.existsById(binId)) {
            throw new BinAlreadyExistsException(binId);
        }

        BinInventory binInventory = new BinInventory();
        binInventory.setBinId(binId);
        binInventory.setStatus(BinStatusEnum.AVAILABLE);
        binInventory.setAssignedDate(null);
        binInventory.setLatitude(null);
        binInventory.setLongitude(null);
        binInventory.setPlasticLevel(0L);
        binInventory.setPaperLevel(0L);
        binInventory.setGlassLevel(0L);
        binInventory.setLastEmptiedAt(null);

        binInventoryRepository.save(binInventory);

        return ApiResponse.<BinInventory>builder()
                .success(true)
                .message("Bin added successfully")
                .data(null)
                .build();
    }

    @Transactional
    public ApiResponse<BinInventory> updateBinLocation(String binId, BinLocationDTO request) {
        BinInventory bin = binInventoryRepository.findById(binId)
                .orElseThrow(() -> new BinNotFoundException(binId));

        bin.setLatitude(request.getLatitude());
        bin.setLongitude(request.getLongitude());

        BinInventory updatedBin = binInventoryRepository.save(bin);

        return ApiResponse.<BinInventory>builder()
                .success(true)
                .message("Bin location updated successfully")
                .data(updatedBin)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    public ApiResponse<Void> deleteBin(String binId) {
        BinInventory bin = binInventoryRepository.findById(binId)
                .orElseThrow(() -> new BinNotFoundException(binId));
        binInventoryRepository.delete(bin);

        return ApiResponse.<Void>builder()
                .success(true)
                .message("Bin deleted successfully")
                .build();
    }

    @Transactional
    public ApiResponse<BinInventory> changeStatus(String binId, BinStatusEnum newStatus) {
        BinInventory bin = binInventoryRepository.findById(binId)
                .orElseThrow(() -> new BinNotFoundException(binId));
        bin.setStatus(newStatus);
        binInventoryRepository.save(bin);

        return ApiResponse.<BinInventory>builder()
                .success(true)
                .message("Bin status updated")
                .data(null)
                .build();
    }

    // FIXED VERSION — Only AVAILABLE bins can be assigned
    @Transactional
    public ApiResponse<BinInventory> assignBinToOwner(String binId, String userId) {
        BinInventory bin = binInventoryRepository.findById(binId)
                .orElseThrow(() -> new BinNotFoundException("Bin not found"));

        if (bin.getStatus() != BinStatusEnum.AVAILABLE) {
            throw new IllegalStateException(
                    "Only AVAILABLE bins can be assigned. Current status: " + bin.getStatus()
            );
        }

        binOwnerProfileRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("Bin owner profile not found"));

        bin.assignToOwner(userId);
        BinInventory savedBin = binInventoryRepository.save(bin);

        return ApiResponse.<BinInventory>builder()
                .success(true)
                .message("Bin successfully assigned")
                .data(savedBin)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }
}

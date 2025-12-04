package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.BinStatusDTO;
import com.smart_wastebackend.exception.BinStatusNotFoundException; // Kept for semantics, but it's really a BinNotFoundException
import com.smart_wastebackend.exception.UserNotFoundException;
import com.smart_wastebackend.model.BinInventory;
// import com.greenpulse.greenpulse_backend.model.BinStatus; // REMOVED: Model is deleted
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.repository.BinInventoryRepository;
// import com.greenpulse.greenpulse_backend.repository.BinStatusRepository; // REMOVED: Repository is deleted
import com.smart_wastebackend.repository.UserTableRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
// import java.util.UUID; // REMOVED: No longer needed

@Service
@Slf4j
public class BinStatusService {

    // REMOVED: This repository is deleted
    // private final BinStatusRepository binStatusRepository;

    private final BinInventoryRepository binInventoryRepository;
    private final UserTableRepository userTableRepository;
    private final NotificationService notificationService;

    @Autowired
    public BinStatusService(
            // BinStatusRepository binStatusRepository, // REMOVED
            BinInventoryRepository binInventoryRepository,
            UserTableRepository userTableRepository,
            NotificationService notificationService
    ) {
        // this.binStatusRepository = binStatusRepository; // REMOVED
        this.binInventoryRepository = binInventoryRepository;
        this.userTableRepository = userTableRepository;
        this.notificationService = notificationService;
    }

    public ApiResponse<BinStatusDTO> getBinStatus(String binId, String userId) { // CHANGED: UUID to String
        BinInventory binInventory = binInventoryRepository.findById(binId)
                .orElseThrow(() -> new BinStatusNotFoundException(binId));

        // CHANGED: Use getOwnerId()
        UserTable user = userTableRepository.findById(binInventory.getOwnerId())
                .orElseThrow(() -> new UserNotFoundException("User not found"));

        if (!user.getId().equals(userId)) {
            throw new UserNotFoundException("User not found for given bin");
        }

        // REMOVED: BinStatus fetch is no longer needed
        // BinStatus binStatus = binStatusRepository.findById(binId)
        //        .orElseThrow(() -> new BinStatusNotFoundException(binId));

        BinStatusDTO binStatusDTO = new BinStatusDTO();
        binStatusDTO.setBinId(binId);

        // CHANGED: Read from binInventory object
        binStatusDTO.setPlasticLevel(binInventory.getPlasticLevel());
        binStatusDTO.setGlassLevel(binInventory.getGlassLevel());
        binStatusDTO.setPaperLevel(binInventory.getPaperLevel());

        return ApiResponse.<BinStatusDTO>builder()
                .success(true)
                .message("Bin status fetched successfully")
                .data(binStatusDTO)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    @Transactional
    public void updateBinLevels(BinStatusDTO binStatusDTO) {
        // CHANGED: Fetch BinInventory
        BinInventory bin = binInventoryRepository.findById(binStatusDTO.getBinId())
                .orElseThrow(() -> new BinStatusNotFoundException("Bin not found for bin: " + binStatusDTO.getBinId()));

        // Store old levels for comparison
        Long oldPlasticLevel = bin.getPlasticLevel();
        Long oldPaperLevel = bin.getPaperLevel();
        Long oldGlassLevel = bin.getGlassLevel();

        // CHANGED: Set levels on BinInventory
        bin.setPlasticLevel(binStatusDTO.getPlasticLevel());
        bin.setPaperLevel(binStatusDTO.getPaperLevel());
        bin.setGlassLevel(binStatusDTO.getGlassLevel());
        binInventoryRepository.save(bin); // CHANGED: Save using BinInventoryRepository

        checkAndTriggerNotifications(bin, oldPlasticLevel, oldPaperLevel, oldGlassLevel); // CHANGED: Pass BinInventory
    }

    @Transactional
    public BinInventory updateLastEmptiedAt(String binId, BinStatusDTO binStatusDTO) { // CHANGED: Return type
        // CHANGED: Fetch BinInventory
        BinInventory bin = binInventoryRepository.findById(binId)
                .orElseThrow(() -> new BinStatusNotFoundException(binId));

        // CHANGED: Set on BinInventory
        bin.setLastEmptiedAt(binStatusDTO.getLastEmptiedAt());
        return binInventoryRepository.save(bin); // CHANGED: Save using BinInventoryRepository
    }


    private void checkAndTriggerNotifications(BinInventory bin, Long oldPlasticLevel, Long oldPaperLevel, Long oldGlassLevel) { // CHANGED: Parameter type
        String binId = bin.getBinId();
        String binOwnerId = getBinOwnerId(binId); // CHANGED: This now returns String

        // Check plastic level
        // CHANGED: Get from bin
        if (isLevelHigh(bin.getPlasticLevel()) && !isLevelHigh(oldPlasticLevel)) {
            int percentage = bin.getPlasticLevel().intValue();
            log.info("High plastic level detected for bin {}: {}%", binId, percentage);
            notificationService.createFillLevelNotification(binId, percentage, binOwnerId); // CHANGThis (binOwnerId is now String)
        }

        // Check paper level
        if (isLevelHigh(bin.getPaperLevel()) && !isLevelHigh(oldPaperLevel)) {
            int percentage = bin.getPaperLevel().intValue();
            log.info("High paper level detected for bin {}: {}%", binId, percentage);
            notificationService.createFillLevelNotification(binId, percentage, binOwnerId); // CHANGED: This (binOwnerId is now String)
        }

        // Check glass level
        if (isLevelHigh(bin.getGlassLevel()) && !isLevelHigh(oldGlassLevel)) {
            int percentage = bin.getGlassLevel().intValue();
            log.info("High glass level detected for bin {}: {}%", binId, percentage);
            notificationService.createFillLevelNotification(binId, percentage, binOwnerId); // CHANGED: This (binOwnerId is now String)
        }
    }

    private boolean isLevelHigh(Long level) {
        return level != null && level >= 90L; // Use 90L for consistency
    }

    private String getBinOwnerId(String binId) { // CHANGED: Return type to String
        BinInventory bin = binInventoryRepository.findById(binId)
                .orElseThrow(() -> new BinStatusNotFoundException("Bin not found: " + binId));
        return bin.getOwnerId(); // CHANGED: Get the direct ID
    }

    public void checkAllBinsForHighLevels() {
        // CHANGED: Use BinInventoryRepository
        List<BinInventory> highLevelBins = binInventoryRepository.findBinsWithHighFillLevel(90L);

        for (BinInventory bin : highLevelBins) { // CHANGED: List type
            checkAndTriggerNotifications(bin, 0L, 0L, 0L); // CHANGED: Pass BinInventory
        }
    }
}
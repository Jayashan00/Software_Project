package com.smart_wastebackend.controller;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.BinStatusDTO;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.service.BinStatusService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/bin/status")
public class BinStatusController {
    private final BinStatusService binStatusService;

    @Autowired
    public BinStatusController(BinStatusService binStatusService) {
        this.binStatusService = binStatusService;
    }

    @GetMapping("/fetch/{binId}")
    @PreAuthorize("hasRole('BIN_OWNER')")
    public ApiResponse<BinStatusDTO> getBinStatus(@PathVariable String binId, @AuthenticationPrincipal UserTable userTable) {
        return binStatusService.getBinStatus(binId, userTable.getId());
    }

    @PostMapping("/check-notifications")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Object> checkAllBinsForHighLevels() {
        binStatusService.checkAllBinsForHighLevels();

        return ApiResponse.builder()
                .success(true)
                .message("Notification check completed")
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

}

package com.smart_wastebackend.dto; // Make sure package is correct

import com.smart_wastebackend.enums.BinStatusEnum;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class BinInventoryResponseDTO {
    private String binId;
    private BinStatusEnum status;
    private LocalDate assignedDate;

    // --- THIS IS THE FIX ---
    private Double latitude;
    private Double longitude;
    // --- END OF FIX ---
}
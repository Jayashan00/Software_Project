package com.smart_wastebackend.dto;

import com.smart_wastebackend.model.CollectorProfile;
import com.smart_wastebackend.model.TruckInventory;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TruckAssignmentResponseDTO {
    private TruckInventory truck;
    private CollectorProfile collector;
    private String assignedDate;
}
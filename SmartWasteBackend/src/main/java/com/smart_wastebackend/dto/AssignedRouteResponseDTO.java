package com.smart_wastebackend.dto;

import com.smart_wastebackend.enums.RouteStatusEnum;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AssignedRouteResponseDTO {
    private String routeId; // CHANGED: Long to String
    private RouteStatusEnum status;
    private LocalDateTime routeStartTime;
    private LocalDateTime routeEndTime;
    private List<BinStopDTO> binStops;
}
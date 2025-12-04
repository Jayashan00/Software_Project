package com.smart_wastebackend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class BinStopDTO {
    // REMOVED: private Long routeStopId;
    private Long stopOrder;
    private String binId;
    private Double latitude;
    private Double longitude; // CHANGED: Renamed from Longitude
    private Long paperLevel;
    private Long plasticLevel;
    private Long glassLevel;
    private LocalDateTime lastEmptiedAt;
}
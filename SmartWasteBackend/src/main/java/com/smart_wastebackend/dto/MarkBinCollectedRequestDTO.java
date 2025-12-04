package com.smart_wastebackend.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MarkBinCollectedRequestDTO {
    private String binId;
    private String routeId; // CHANGED: Long to String
}
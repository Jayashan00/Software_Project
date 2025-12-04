package com.smart_wastebackend.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class BinStatusDTO {
    private String binId;
    private Long plasticLevel;
    private Long paperLevel;
    private Long glassLevel;
    private LocalDateTime lastEmptiedAt;
}

package com.smart_wastebackend.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

// import java.util.UUID; // REMOVED

@Getter
@Setter
public class ChangeOwnerRequestDTO {
    @NotNull
    private String newOwnerId; // CHANGED: UUID to String
}
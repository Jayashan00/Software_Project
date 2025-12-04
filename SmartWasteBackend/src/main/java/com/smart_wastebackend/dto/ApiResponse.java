package com.smart_wastebackend.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor

@JsonInclude(JsonInclude.Include.NON_NULL)


public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;
    private String timestamp = LocalDateTime.now().toString();
}

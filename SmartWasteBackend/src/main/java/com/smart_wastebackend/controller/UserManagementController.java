package com.smart_wastebackend.controller;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.ProfileUpdateRequestDTO;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.service.UserTableService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/admin/users")
public class UserManagementController {

    private final UserTableService userTableService;

    @Autowired
    public UserManagementController(UserTableService userTableService) {
        this.userTableService = userTableService;
    }

    // ✅ Fetch all users (Admin only)
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<UserTable>>> getAllUsers() {
        ApiResponse<List<UserTable>> response = userTableService.getAllUsers();
        return ResponseEntity.ok(response);
    }

    // ✅ Fetch current logged-in user's profile
    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<UserTable>> getCurrentUserProfile(
            @AuthenticationPrincipal UserTable user
    ) {
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        return ResponseEntity.ok(ApiResponse.<UserTable>builder()
                .success(true)
                .message("User profile fetched successfully")
                .data(user)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

    // ✅ Update current user's profile
    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<UserTable>> updateProfile(
            @AuthenticationPrincipal UserTable user,
            @RequestBody ProfileUpdateRequestDTO profileUpdateRequestDTO
    ) {
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.<UserTable>builder()
                            .success(false)
                            .message("User not authenticated")
                            .timestamp(LocalDateTime.now().toString())
                            .build());
        }

        UserTable updatedUser = userTableService.updateUserProfile(user.getId(), profileUpdateRequestDTO);

        return ResponseEntity.ok(ApiResponse.<UserTable>builder()
                .success(true)
                .message("Profile updated successfully")
                .data(updatedUser)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }
}

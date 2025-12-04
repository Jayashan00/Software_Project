package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.ProfileUpdateRequestDTO;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.repository.UserTableRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class UserTableService {

    private final UserTableRepository userTableRepository;

    @Autowired
    public UserTableService(UserTableRepository userTableRepository) {
        this.userTableRepository = userTableRepository;
    }

    public ApiResponse<List<UserTable>> getAllUsers() {
        List<UserTable> users = userTableRepository.findAll();

        return ApiResponse.<List<UserTable>>builder()
                .success(true)
                .message("Users fetched successfully")
                .data(users)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    // ✅ Update user profile
    public UserTable updateUserProfile(String userId, ProfileUpdateRequestDTO profileUpdateRequestDTO) {
        UserTable user = userTableRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setFullName(profileUpdateRequestDTO.getName());
        userTableRepository.save(user);

        return user;
    }
}

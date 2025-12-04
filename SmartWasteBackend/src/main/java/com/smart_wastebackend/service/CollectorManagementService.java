package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.CollectorCreateRequestDTO;
import com.smart_wastebackend.enums.UserRoleEnum;
// import com.greenpulse.greenpulse_backend.exception.UserRoleNotFoundException; // REMOVED
import com.smart_wastebackend.exception.UsernameAlreadyExistsException;
import com.smart_wastebackend.model.CollectorProfile;
// import com.greenpulse.greenpulse_backend.model.UserRole; // REMOVED
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.repository.CollectorProfileRepository;
// import com.greenpulse.greenpulse_backend.repository.UserRoleRepository; // REMOVED
import com.smart_wastebackend.repository.UserTableRepository;
import org.springframework.transaction.annotation.Transactional; // CHANGED
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
// import java.util.UUID; // REMOVED

@Service
public class CollectorManagementService {

    private final UserTableRepository userRepository;
    private final CollectorProfileRepository collectorProfileRepository;
    // private final UserRoleRepository userRoleRepository; // REMOVED
    private final PasswordEncoder passwordEncoder;

    public CollectorManagementService(
            UserTableRepository userRepository,
            CollectorProfileRepository collectorProfileRepository,
            // UserRoleRepository userRoleRepository, // REMOVED
            PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.collectorProfileRepository = collectorProfileRepository;
        // this.userRoleRepository = userRoleRepository; // REMOVED
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public ApiResponse<String> createCollector(CollectorCreateRequestDTO request) {
        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            throw new UsernameAlreadyExistsException("Username already exists");
        }

        // REMOVED: UserRole fetch is no longer needed
        // UserRole userRole = userRoleRepository.findByRole(UserRoleEnum.ROLE_COLLECTOR)
        //        .orElseThrow(() -> new UserRoleNotFoundException("BIN_OWNER role not found"));

        UserTable user = new UserTable();
        user.setUsername(request.getUsername());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole(UserRoleEnum.ROLE_COLLECTOR); // CHANGED: Set enum directly
        user.setCreatedAt(LocalDateTime.now());

        // Save the user first to generate its String ID
        userRepository.save(user);

        CollectorProfile profile = new CollectorProfile();
        profile.setId(user.getId()); // CHANGED: Set the same ID as the user
        // profile.setUser(user); // REMOVED
        profile.setName(request.getName());

        collectorProfileRepository.save(profile);

        return ApiResponse.<String>builder()
                .success(true)
                .message("Collector created successfully")
                .data(null)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    @Transactional
    public ApiResponse<String> deleteCollector(String id) { // CHANGED: UUID to String
        if (!userRepository.existsById(id)) {
            throw new IllegalArgumentException("Collector not found with id " + id);
        }

        collectorProfileRepository.deleteById(id);
        userRepository.deleteById(id);

        return ApiResponse.<String>builder()
                .success(true)
                .message("Collector deleted successfully")
                .data(null)
                .timestamp(LocalDateTime.now().toString())
                .build();
    }
}
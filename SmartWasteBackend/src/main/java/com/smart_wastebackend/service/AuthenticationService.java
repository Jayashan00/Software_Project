package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.AuthenticationDataDTO;
import com.smart_wastebackend.dto.AuthenticationRequestDTO;
import com.smart_wastebackend.dto.RegisterRequestDTO;
import com.smart_wastebackend.enums.UserRoleEnum;
import com.smart_wastebackend.exception.AuthenticationFailedException;
import com.smart_wastebackend.exception.UsernameAlreadyExistsException;
import com.smart_wastebackend.model.BinOwnerProfile;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.repository.BinOwnerProfileRepository;
import com.smart_wastebackend.repository.UserTableRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // Use Spring's @Transactional

import java.time.LocalDateTime;

@Service
public class AuthenticationService {

    private final UserTableRepository userTableRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final BinOwnerProfileRepository binOwnerProfileRepository;
    private final EmailVerificationService emailVerificationService;

    @Autowired
    public AuthenticationService(
            UserTableRepository userTableRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            AuthenticationManager authenticationManager,
            BinOwnerProfileRepository binOwnerProfileRepository,
            EmailVerificationService emailVerificationService
    ) {
        this.userTableRepository = userTableRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.binOwnerProfileRepository = binOwnerProfileRepository;
        this.emailVerificationService = emailVerificationService;
    }

    @Transactional
    public ApiResponse<AuthenticationDataDTO> register(RegisterRequestDTO request) {
        if (userTableRepository.findByUsername(request.getUsername()).isPresent()) {
            throw new UsernameAlreadyExistsException("Email already exists");
        }

        UserTable user = new UserTable();
        user.setUsername(request.getUsername());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole(UserRoleEnum.ROLE_BIN_OWNER); // Set role directly
        user.setCreatedAt(LocalDateTime.now());

        // Save user first to get the generated ID
        userTableRepository.save(user);

        BinOwnerProfile binOwnerProfile = new BinOwnerProfile();
        binOwnerProfile.setId(user.getId()); // Use the same ID as UserTable
        binOwnerProfile.setName(request.getName());
        binOwnerProfile.setAddress(request.getAddress());
        binOwnerProfile.setMobileNumber(request.getMobileNumber());
        binOwnerProfile.setEmailVerified(false);

        binOwnerProfileRepository.save(binOwnerProfile);

        emailVerificationService.generateEmailVerificationCode(user.getId()); // Pass String ID

        var jwtToken = jwtService.generateToken(user);

        return ApiResponse.<AuthenticationDataDTO>builder()
                .success(true)
                .message("Registration Successful")
                .data(new AuthenticationDataDTO(jwtToken))
                .timestamp(LocalDateTime.now().toString())
                .build();
    }

    public ApiResponse<AuthenticationDataDTO> authenticate(AuthenticationRequestDTO request) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );
        } catch (Exception ex) {
            throw new AuthenticationFailedException("Invalid username or password");
        }


        var user = userTableRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        var jwtToken = jwtService.generateToken(user);

        return  ApiResponse.<AuthenticationDataDTO>builder()
                .success(true)
                .message("Login Successful")
                .data(new AuthenticationDataDTO(jwtToken))
                .timestamp(LocalDateTime.now().toString())
                .build();
    }
    // ... inside AuthenticationService class ...

    public void changePassword(String username, String currentPassword, String newPassword) {
        UserTable user = userTableRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            throw new IllegalArgumentException("Incorrect current password");
        }

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userTableRepository.save(user);
    }
}
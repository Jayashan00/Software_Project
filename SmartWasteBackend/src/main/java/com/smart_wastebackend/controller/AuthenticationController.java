package com.smart_wastebackend.controller;

import com.smart_wastebackend.dto.*;

import com.smart_wastebackend.exception.InvalidPinException;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.service.AuthenticationService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import com.smart_wastebackend.service.PasswordResetService;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@CrossOrigin(origins = "http://localhost:5173")
@RequestMapping("/api/auth")
public class AuthenticationController {

    private final AuthenticationService authenticationService;
    private final PasswordResetService passwordResetService;

    public AuthenticationController(AuthenticationService authenticationService, PasswordResetService passwordResetService) {
        this.authenticationService = authenticationService;
        this.passwordResetService = passwordResetService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthenticationDataDTO>> register(
            @RequestBody RegisterRequestDTO request
    ) {
        return ResponseEntity.ok(authenticationService.register(request));
    }

    @PostMapping("/authenticate")
    public ResponseEntity<ApiResponse<AuthenticationDataDTO>> authenticate(
            @RequestBody AuthenticationRequestDTO request
    ) {
        return ResponseEntity.ok(authenticationService.authenticate(request));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<ApiResponse<PasswordResetResponseDTO>> forgotPassword(
            @Valid @RequestBody ForgotPasswordRequestDTO request) {

        PasswordResetResponseDTO response = passwordResetService.sendResetEmail(request.getEmail());

        return ResponseEntity.ok(ApiResponse.<PasswordResetResponseDTO>builder()
                .success(true)
                .message("If email exists, reset PIN has been sent")
                .data(response)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

    @PostMapping("/verify-reset-pin")
    public ResponseEntity<ApiResponse<PasswordResetResponseDTO>> verifyResetPin(
            @AuthenticationPrincipal UserTable user,
            @Valid @RequestBody VerifyResetPinRequestDTO request) {

        PasswordResetResponseDTO response = passwordResetService.verifyResetPin(
                request.getPin(),
                request.getEmail()
        );

        return ResponseEntity.ok(ApiResponse.<PasswordResetResponseDTO>builder()
                .success(true)
                .message("PIN verified successfully")
                .data(response)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Object>> resetPassword(
            @AuthenticationPrincipal UserTable user,
            @Valid @RequestBody ResetPasswordRequestDTO request) {

        if (user == null) {
            throw new InvalidPinException("User not authenticated");
        }

        passwordResetService.resetPassword(request.getNewPassword());

        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Password reset successfully")
                .data(null)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }


    @PostMapping("/resend-reset-pin")
    public ResponseEntity<ApiResponse<Object>> resendResetPin(
            @AuthenticationPrincipal UserTable user,
            @RequestBody Map<String, String> request) {

        passwordResetService.resendResetPin(request.get("email"));

        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Reset PIN resent successfully")
                .data(null)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }
    // ... inside AuthenticationController class ...

    @PostMapping("/change-password")
    public ResponseEntity<ApiResponse<Object>> changePassword(
            @AuthenticationPrincipal UserTable user,
            @RequestBody @Valid ChangePasswordDTO request) {

        authenticationService.changePassword(user.getUsername(), request.getCurrentPassword(), request.getNewPassword());

        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Password changed successfully")
                .build());
    }


}
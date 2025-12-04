package com.smart_wastebackend.controller;

import com.smart_wastebackend.dto.ApiResponse;
import com.smart_wastebackend.dto.VerifyPinRequestDTO;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.service.EmailVerificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
// import java.util.UUID; // REMOVED

@RestController
@RequestMapping("/api/email-verification")
public class EmailVerificationController {

    private final EmailVerificationService emailVerificationService;

    @Autowired
    public EmailVerificationController(EmailVerificationService emailVerificationService) {
        this.emailVerificationService = emailVerificationService;
    }

    @PostMapping("/send-pin")
    public ResponseEntity<ApiResponse<Object>> sendVerificationCode(
            @AuthenticationPrincipal UserTable user) {

        // CHANGED: No longer need to cast to UUID, just pass the String ID
        emailVerificationService.generateEmailVerificationCode(user.getId());

        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Email verification PIN sent successfully")
                .data(null)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }


    @PostMapping("/verify")
    public ResponseEntity<ApiResponse<Object>> verifyPin(@AuthenticationPrincipal UserTable user, @RequestBody VerifyPinRequestDTO request) {
        // This is already correct, user.getId() is a String
        emailVerificationService.verifyEmail(user.getId(), request.getPin());
        return ResponseEntity.ok(ApiResponse.builder()
                .success(true)
                .message("Email verified successfully")
                .data(null)
                .timestamp(LocalDateTime.now().toString())
                .build());
    }

}
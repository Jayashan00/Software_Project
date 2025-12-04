package com.smart_wastebackend.service;

import com.smart_wastebackend.dto.PasswordResetResponseDTO;
import com.smart_wastebackend.exception.InvalidPinException;
import com.smart_wastebackend.model.PasswordResetToken;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.repository.PasswordResetTokenRepository;
import com.smart_wastebackend.repository.UserTableRepository;
import org.springframework.transaction.annotation.Transactional; // CHANGED
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Random;
// import java.util.UUID; // REMOVED

@Service
public class PasswordResetService {

    private final UserTableRepository userTableRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService; // Add JWT service

    @Autowired
    public PasswordResetService(
            UserTableRepository userTableRepository,
            PasswordResetTokenRepository passwordResetTokenRepository,
            EmailService emailService,
            PasswordEncoder passwordEncoder,
            JwtService jwtService // Inject JWT service
    ) {
        this.userTableRepository = userTableRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.emailService = emailService;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public PasswordResetResponseDTO sendResetEmail(String email) {
        UserTable user = userTableRepository.findByUsername(email).orElse(null);

        if (user != null) {
            // Clean up any existing tokens for this user
            // CHANGED: Pass String ID
            passwordResetTokenRepository.deleteByUserId(user.getId());

            // Generate 6-digit PIN
            String pin = generateSixDigitPin();

            // Generate JWT token instead of UUID - this is the key change
            String jwtToken = jwtService.generateToken(user);

            // Save token and PIN to database
            PasswordResetToken resetToken = PasswordResetToken.builder()
                    .userId(user.getId()) // CHANGED: Set String ID
                    .token(jwtToken) // Store JWT token
                    .pin(pin)
                    .expiresAt(LocalDateTime.now().plusMinutes(10))
                    .createdAt(LocalDateTime.now())
                    .build();

            passwordResetTokenRepository.save(resetToken);

            // Send PIN via email
            try {
                emailService.sendPasswordResetEmail(user.getUsername(), pin);
                System.out.println("Password reset PIN sent to: " + user.getUsername());
            } catch (Exception e) {
                System.err.println("Failed to send email: " + e.getMessage());
                e.printStackTrace();
            }

            return PasswordResetResponseDTO.builder()
                    .sessionToken(jwtToken) // Return JWT token
                    .email(email)
                    .expiresIn(10 * 60 * 1000L)
                    .build();
        }

        // Return dummy response for security
        return PasswordResetResponseDTO.builder()
                .sessionToken(generateDummyJwtToken()) // Generate dummy JWT
                .email(email)
                .expiresIn(10 * 60 * 1000L)
                .build();
    }

    @Transactional
    public PasswordResetResponseDTO verifyResetPin(String pin, String email) {
        // Get authenticated user from Spring Security context
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserTable authenticatedUser = (UserTable) authentication.getPrincipal();

        // Verify email matches authenticated user
        if (!authenticatedUser.getUsername().equals(email)) {
            throw new InvalidPinException("Email mismatch");
        }

        // Find the reset token record for this user
        // CHANGED: Pass String ID
        PasswordResetToken resetToken = passwordResetTokenRepository
                .findByUserIdAndPin(authenticatedUser.getId(), pin)
                .orElseThrow(() -> new InvalidPinException("Invalid PIN"));

        // Check if token is expired
        if (resetToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            passwordResetTokenRepository.delete(resetToken);
            throw new InvalidPinException("Reset session has expired");
        }

        // Generate new JWT token for password reset phase
        String verifiedJwtToken = jwtService.generateToken(authenticatedUser);
        resetToken.setToken(verifiedJwtToken);
        resetToken.setPin(null); // Clear PIN after verification
        resetToken.setExpiresAt(LocalDateTime.now().plusMinutes(5));
        passwordResetTokenRepository.save(resetToken);

        return PasswordResetResponseDTO.builder()
                .verifiedToken(verifiedJwtToken) // Return new JWT token
                .email(email)
                .expiresIn(5 * 60 * 1000L)
                .build();
    }

    @Transactional
    public void resetPassword(String newPassword) {
        // Get authenticated user from Spring Security context
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            throw new InvalidPinException("User not authenticated");
        }

        UserTable authenticatedUser = (UserTable) authentication.getPrincipal();

        // Find any active reset token for this user (where PIN is null = verified)
        // CHANGED: Pass String ID
        PasswordResetToken resetToken = passwordResetTokenRepository
                .findByUserIdAndPinIsNull(authenticatedUser.getId())
                .orElseThrow(() -> new InvalidPinException("Invalid verification token"));

        // Check if token is expired
        if (resetToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            passwordResetTokenRepository.delete(resetToken);
            throw new InvalidPinException("Verification token has expired");
        }

        // Update password
        authenticatedUser.setPasswordHash(passwordEncoder.encode(newPassword));
        userTableRepository.save(authenticatedUser);

        // Clean up token
        passwordResetTokenRepository.delete(resetToken);
    }


    @Transactional
    public void resendResetPin(String email) {
        // Get authenticated user from Spring Security context
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserTable authenticatedUser = (UserTable) authentication.getPrincipal();

        // Verify email matches authenticated user
        if (!authenticatedUser.getUsername().equals(email)) {
            throw new InvalidPinException("Email mismatch");
        }

        // CHANGED: Pass String ID
        PasswordResetToken resetToken = passwordResetTokenRepository
                .findByUserId(authenticatedUser.getId())
                .orElseThrow(() -> new InvalidPinException("No active reset session"));

        // Generate new PIN
        String newPin = generateSixDigitPin();
        resetToken.setPin(newPin);
        resetToken.setExpiresAt(LocalDateTime.now().plusMinutes(10));
        passwordResetTokenRepository.save(resetToken);

        // Send new PIN via email
        emailService.sendPasswordResetEmail(email, newPin);
    }

    private String generateSixDigitPin() {
        Random random = new Random();
        int pin = 100000 + random.nextInt(900000);
        return String.valueOf(pin);
    }

    private String generateDummyJwtToken() {
        // Create a dummy user for security purposes
        UserTable dummyUser = new UserTable();
        dummyUser.setUsername("dummy@example.com");
        return jwtService.generateToken(dummyUser);
    }
}
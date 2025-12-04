package com.smart_wastebackend.service;

import com.smart_wastebackend.exception.InvalidPinException;
import com.smart_wastebackend.exception.PinExpiredException;
import com.smart_wastebackend.exception.TooSoonException;
import com.smart_wastebackend.model.BinOwnerProfile;
import com.smart_wastebackend.model.EmailVerification;
import com.smart_wastebackend.model.UserTable;
import com.smart_wastebackend.repository.BinOwnerProfileRepository;
import com.smart_wastebackend.repository.EmailVerificationRepository;
import com.smart_wastebackend.exception.VerificationCodeNotFoundException;
import com.smart_wastebackend.repository.UserTableRepository;
import org.springframework.transaction.annotation.Transactional; // Use Spring's @Transactional
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Optional;
// import java.util.UUID; // No longer needed

@Service
public class EmailVerificationService {
    private final EmailVerificationRepository emailVerificationRepository;
    private final BinOwnerProfileRepository binOwnerProfileRepository;
    private final EmailService emailService;
    private final UserTableRepository userTableRepository;

    @Autowired
    public EmailVerificationService(
            EmailVerificationRepository emailVerificationRepository,
            BinOwnerProfileRepository binOwnerProfileRepository,
            EmailService emailService,
            UserTableRepository userTableRepository
    ) {
        this.emailVerificationRepository = emailVerificationRepository;
        this.binOwnerProfileRepository = binOwnerProfileRepository;
        this.emailService = emailService;
        this.userTableRepository = userTableRepository;
    }

    @Transactional
    public void generateEmailVerificationCode(String userId) { // CHANGED: UUID to String
        // Check if the user/profile exists
        binOwnerProfileRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        Optional<EmailVerification> existing = emailVerificationRepository.findById(userId);

        if (existing.isPresent()) {
            LocalDateTime lastSent = existing.get().getCreatedAt();
            if (lastSent.plusMinutes(1).isAfter(LocalDateTime.now())) {
                throw new TooSoonException("Please wait at least 1 minute before requesting another PIN");
            }
        }


        // Remove previously stored code if exists
        emailVerificationRepository.deleteById(userId);

        String pin = generatePin();

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiry = now.plusMinutes(10);

        EmailVerification emailVerification = new EmailVerification();
        emailVerification.setId(userId); // CHANGED: Set the ID directly
        emailVerification.setVerificationToken(pin);
        // emailVerification.setBinOwner(binOwner); // REMOVED: This relationship is gone
        emailVerification.setCreatedAt(now);
        emailVerification.setExpiresAt(expiry);

        emailVerificationRepository.save(emailVerification);

        UserTable userTable = userTableRepository.findById(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        emailService.sendVerificationEmail(userTable.getUsername(), pin);
    }

    @Transactional
    public void verifyEmail(String userId, String verificationToken) { // CHANGED: UUID to String
        EmailVerification verification = emailVerificationRepository.findById(userId)
                .orElseThrow(() -> new VerificationCodeNotFoundException("No verification code found"));

        if(!verification.getVerificationToken().equals(verificationToken)) {
            throw new InvalidPinException("Invalid PIN");
        }

        if(verification.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new PinExpiredException("PIN expired");
        }

        // CHANGED: Fetch the owner directly by ID
        BinOwnerProfile owner = binOwnerProfileRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        owner.setEmailVerified(true);
        binOwnerProfileRepository.save(owner);
        emailVerificationRepository.deleteById(userId);
    }

    private String generatePin() {
        SecureRandom random = new SecureRandom();
        int number = random.nextInt(900_000) + 100_000; // generates 6-digit number
        return String.valueOf(number);
    }
}
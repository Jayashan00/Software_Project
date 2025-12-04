package com.smart_wastebackend.repository;

import com.smart_wastebackend.model.PasswordResetToken;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface PasswordResetTokenRepository extends MongoRepository<PasswordResetToken, String> {

    Optional<PasswordResetToken> findByToken(String token);

    Optional<PasswordResetToken> findByUserIdAndPin(String userId, String pin);

    Optional<PasswordResetToken> findByUserIdAndPinIsNull(String userId);

    Optional<PasswordResetToken> findByUserId(String userId);

    void deleteByUserId(String userId);

    void deleteByExpiresAtBefore(LocalDateTime currentTime);
}
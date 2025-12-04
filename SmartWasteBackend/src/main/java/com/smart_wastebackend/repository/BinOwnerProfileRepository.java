package com.smart_wastebackend.repository;

import com.smart_wastebackend.model.BinOwnerProfile;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BinOwnerProfileRepository extends MongoRepository<BinOwnerProfile, String> {
    // ID type changed from UUID to String
}
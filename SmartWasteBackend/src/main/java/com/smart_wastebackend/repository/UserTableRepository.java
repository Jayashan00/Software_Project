package com.smart_wastebackend.repository;

import com.smart_wastebackend.enums.UserRoleEnum;
import com.smart_wastebackend.model.UserTable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserTableRepository extends MongoRepository<UserTable, String> {

    Optional<UserTable> findByUsername(String username);

    List<UserTable> findByRole(UserRoleEnum roleEnum);
}

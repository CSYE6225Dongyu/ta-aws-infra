package edu.neu.csye6225.csye6225fall2024.repository;

import edu.neu.csye6225.csye6225fall2024.model.UserModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public interface UserRepository extends JpaRepository<UserModel, Long> {
    Optional<UserModel> findByEmail(String email);
}

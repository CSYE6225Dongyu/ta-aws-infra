package edu.neu.csye6225.csye6225fall2024.service;

import edu.neu.csye6225.csye6225fall2024.dto.UserPostDTO;
import edu.neu.csye6225.csye6225fall2024.dto.UserGETDTO;
import edu.neu.csye6225.csye6225fall2024.dto.UserUpdateDTO;
import edu.neu.csye6225.csye6225fall2024.model.UserModel;
import edu.neu.csye6225.csye6225fall2024.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;


@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;// password class from AuthorizeConfig

    //create user
    public void createUser(UserPostDTO userPostDTO) {
        //check the user
        Optional<UserModel> existUser = userRepository.findByEmail(userPostDTO.getEmail());
        if (existUser.isPresent()) {
            throw new IllegalArgumentException("User email already exists.");
        }

        if(userPostDTO.getEmail() == null || userPostDTO.getPassword() == null || userPostDTO.getLastName() == null)
            throw new IllegalArgumentException("missing filed required");

        UserModel user = new UserModel();
        user.setEmail(userPostDTO.getEmail());
        // bycrypt
        user.setPassword(passwordEncoder.encode(userPostDTO.getPassword()));

        user.setFirstName(userPostDTO.getFirstName());
        user.setLastName(userPostDTO.getLastName());

        user.setAccountCreated(LocalDateTime.now());
        user.setAccountUpdated(LocalDateTime.now());

        // save to database
        userRepository.save(user);
    }

    public void updateUser(String email, UserUpdateDTO userUpdateDTO) {
        UserModel user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));


        // when called, must change something
        boolean updated = false;
        if (userUpdateDTO.getFirstName() != null) {
            user.setFirstName(userUpdateDTO.getFirstName());
            updated = true;
        }
        if (userUpdateDTO.getLastName() != null) {
            user.setLastName(userUpdateDTO.getLastName());
            updated = true;
        }
        if (userUpdateDTO.getPassword() != null) {
            user.setPassword(passwordEncoder.encode(userUpdateDTO.getPassword()));
            updated = true;
        }
        // exception when nothing changes
        if (!updated)
            throw new IllegalArgumentException("No valid fields to update");

        user.setAccountUpdated(LocalDateTime.now());

        userRepository.save(user);
    }

    public UserGETDTO getUserByEmail(String email) {
        UserModel user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return new UserGETDTO(
                user.getId(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getAccountCreated(),
                user.getAccountUpdated()
        );
    }
}

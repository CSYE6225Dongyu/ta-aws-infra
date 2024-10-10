package edu.neu.csye6225.csye6225fall2024.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.exc.UnrecognizedPropertyException;
import edu.neu.csye6225.csye6225fall2024.dto.UserPostDTO;
import edu.neu.csye6225.csye6225fall2024.dto.UserGETDTO;
import edu.neu.csye6225.csye6225fall2024.dto.UserUpdateDTO;
import edu.neu.csye6225.csye6225fall2024.service.ValidateFields;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import edu.neu.csye6225.csye6225fall2024.service.UserService;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/v1/users")
public class UserController {

    @Autowired
    private UserService userService;
    @Autowired
    private ValidateFields validateFields;

    @PostMapping
    public ResponseEntity<UserGETDTO> creatUser(@RequestBody Map<String, Object> requestBody) {

        // validate json
        String invalidField = validateFields.postValidate(requestBody);
        if (invalidField != null) {
            return ResponseEntity.badRequest().body(null);
        }

        // transfer to DTO type
        UserPostDTO userPostDTO = new ObjectMapper().convertValue(requestBody, UserPostDTO.class);

        try {
            // create user
            userService.createUser(userPostDTO);
            // return info
            UserGETDTO userGETDTO = userService.getUserByEmail(userPostDTO.getEmail());
            return ResponseEntity.status(HttpStatus.CREATED).body(userGETDTO);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    @GetMapping("/self")
    public ResponseEntity<UserGETDTO> getUser() {
        try {
            String email = getCurrentUserEmail();
            UserGETDTO user = userService.getUserByEmail(email);
            return ResponseEntity.ok(user);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    @PutMapping("/self")
    public ResponseEntity<String> updateUser(@RequestBody Map<String, Object> requestBody) {
        if(validateFields.updateValidate(requestBody) != null)
            return ResponseEntity.badRequest().body("Unexpected field: " + validateFields.updateValidate(requestBody));

        UserUpdateDTO userUpdateDTO = new ObjectMapper().convertValue(requestBody, UserUpdateDTO.class);

        try {
            String email = getCurrentUserEmail();
            userService.updateUser(email, userUpdateDTO);
            return ResponseEntity.status(HttpStatus.NO_CONTENT).body("User updated success");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error occurred while updating user");
        }
    }

    //get emial form SecurityContextHolder
    private String getCurrentUserEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication.getName();
    }

//    //Unrecognized filed
//    @ExceptionHandler(UnrecognizedPropertyException.class)
//    public ResponseEntity<String> handleUnrecognizedPropertyException(UnrecognizedPropertyException ex) {
//        String errorMessage = "Invalid JSON field: " + ex.getPropertyName();
//        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorMessage);
//    }

    @RequestMapping(method = {RequestMethod.GET, RequestMethod.PUT, RequestMethod.DELETE,RequestMethod.OPTIONS,RequestMethod.HEAD,RequestMethod.PATCH,RequestMethod.TRACE})
    public ResponseEntity<String> invalidMethod() {
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                .header("Cache-Control", "no-cache, no-store, must-revalidate")
                .header("Pragma", "no-cache")
                .build();
    }

    @RequestMapping(value = "/self", method = {RequestMethod.DELETE, RequestMethod.OPTIONS, RequestMethod.HEAD, RequestMethod.PATCH, RequestMethod.TRACE, RequestMethod.POST})
    public ResponseEntity<String> invalidSelfMethod() {
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                .header("Cache-Control", "no-cache, no-store, must-revalidate")
                .header("Pragma", "no-cache")
                .build();
    }


}

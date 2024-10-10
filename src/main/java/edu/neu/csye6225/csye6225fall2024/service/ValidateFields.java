package edu.neu.csye6225.csye6225fall2024.service;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Service
public class ValidateFields {
    private final List<String> postValidFields = Arrays.asList("email", "password", "firstName", "lastName");
    private final List<String> updateValidFields = Arrays.asList("password", "firstName", "lastName");

    public String postValidate(Map<String, Object> requestBody) {
        for (String key : requestBody.keySet()) {
            if (!postValidFields.contains(key)) {
                return key;
            }
        }
        return null;
    }

    public String updateValidate(Map<String, Object> requestBody) {
        for (String key : requestBody.keySet()) {
            if (!updateValidFields.contains(key)) {
                return key;
            }
        }
        return null;
    }
}

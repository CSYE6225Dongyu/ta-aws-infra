package edu.neu.csye6225.csye6225fall2024.controller;


import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;


import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/healthz")
public class HealthCheckController {

    @Autowired
    private DataSource dataSource;

    //request method
    @RequestMapping(method = RequestMethod.GET)
    public ResponseEntity<String> DBHealthCheck(HttpServletRequest request) {
        Map<String, String> response = new HashMap<>();

        // If body has payload, return bad request
        // use HttpServletRequest class make sure cover all type of body data
        if(request.getContentLengthLong() > 0 || request.getContentType() != null) {
            return ResponseEntity.badRequest()
                    .header("Cache-Control", "no-cache, no-store, must-revalidate")
                    .header("Pragma", "no-cache")
                    .build();
        }

        if(!request.getParameterMap().isEmpty()){
            return ResponseEntity.badRequest()
                    .header("Cache-Control", "no-cache, no-store, must-revalidate")
                    .header("Pragma", "no-cache")
                    .build();
        }
        try(Connection conn = dataSource.getConnection()) {
            if (conn.isValid(1)) {
                //conn is valid
                return ResponseEntity.ok()
                        .header("Cache-Control", "no-cache, no-store, must-revalidate")
                        .header("Pragma", "no-cache")
                        .build();
            } else { // Conn failed
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                        .header("Cache-Control", "no-cache, no-store, must-revalidate")
                        .header("Pragma", "no-cache")
                        .build();
            }
        } catch (SQLException e) {
            // exception
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .header("Cache-Control", "no-cache, no-store, must-revalidate")
                    .header("Pragma", "no-cache")
                    .build();
        }
    }

    @RequestMapping(method = {RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE,RequestMethod.OPTIONS,RequestMethod.HEAD,RequestMethod.PATCH,RequestMethod.TRACE})
    public ResponseEntity<String> invalidMethod() {
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED)
                .header("Cache-Control", "no-cache, no-store, must-revalidate")
                .header("Pragma", "no-cache")
                .build();
    }
}

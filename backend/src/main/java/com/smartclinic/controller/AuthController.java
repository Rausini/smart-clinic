package com.smartclinic.controller;

import com.smartclinic.dto.AuthResponse;
import com.smartclinic.dto.LoginRequest;
import com.smartclinic.repository.AdminRepository;
import com.smartclinic.repository.DoctorRepository;
import com.smartclinic.repository.PatientRepository;
import com.smartclinic.service.TokenService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;
    private final TokenService tokenService;
    private final DoctorRepository doctorRepository;
    private final PatientRepository patientRepository;
    private final AdminRepository adminRepository;

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        UserDetails userDetails = userDetailsService.loadUserByUsername(request.getEmail());
        String token = tokenService.generateToken(userDetails);

        // Resolve userId and name based on role
        String role = request.getRole().toUpperCase();
        Long userId = null;
        String name = null;

        switch (role) {
            case "ADMIN" -> {
                var admin = adminRepository.findByEmail(request.getEmail()).orElseThrow();
                userId = admin.getId();
                name = admin.getName();
            }
            case "DOCTOR" -> {
                var doctor = doctorRepository.findByEmail(request.getEmail()).orElseThrow();
                userId = doctor.getId();
                name = doctor.getName();
            }
            case "PATIENT" -> {
                var patient = patientRepository.findByEmail(request.getEmail()).orElseThrow();
                userId = patient.getId();
                name = patient.getName();
            }
        }

        AuthResponse response = AuthResponse.builder()
                .token(token)
                .role(role)
                .userId(userId)
                .name(name)
                .email(request.getEmail())
                .build();

        return ResponseEntity.ok(response);
    }
}

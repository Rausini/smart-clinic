package com.smartclinic.service;

import com.smartclinic.dto.DoctorRequest;
import com.smartclinic.entity.Appointment;
import com.smartclinic.entity.Doctor;
import com.smartclinic.repository.AppointmentRepository;
import com.smartclinic.repository.DoctorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DoctorService {

    private final DoctorRepository doctorRepository;
    private final PasswordEncoder passwordEncoder;
    private final AppointmentRepository appointmentRepository;
    private final TokenService tokenService;

    public List<Doctor> getAllDoctors() {
        return doctorRepository.findAll();
    }

    public Doctor getDoctorById(Long id) {
        return doctorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Doctor not found with id: " + id));
    }

    public Doctor createDoctor(DoctorRequest request) {
        if (doctorRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already in use: " + request.getEmail());
        }
        Doctor doctor = Doctor.builder()
                .name(request.getName())
                .speciality(request.getSpeciality())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .availableTimes(request.getAvailableTimes())
                .build();
        return doctorRepository.save(doctor);
    }

    public List<Doctor> findBySpeciality(String speciality) {
        return doctorRepository.findBySpecialityIgnoreCase(speciality);
    }

    public List<Doctor> findByName(String name) {
        return doctorRepository.findByNameContainingIgnoreCase(name);
    }

    public void deleteDoctor(Long id) {
        doctorRepository.deleteById(id);
    }

    public List<String> getAvailableTimes(Long doctorId, LocalDate date, String token) {
        tokenService.extractUsername(token);
        Doctor doctor = getDoctorById(doctorId);
        List<LocalTime> booked = appointmentRepository
                .findByDoctorIdAndAppointmentDate(doctorId, date)
                .stream()
                .map(Appointment::getAppointmentTime)
                .toList();
        List<String> times = doctor.getAvailableTimes();
        if (times == null) return List.of();
        return times.stream()
                .filter(slot -> !booked.contains(LocalTime.parse(slot)))
                .toList();
    }

    public boolean validateLogin(String email, String password) {
        return doctorRepository.findByEmail(email)
                .map(d -> passwordEncoder.matches(password, d.getPassword()))
                .orElse(false);
    }
}

package com.smart_wastebackend.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {
    private final JavaMailSender mailSender;

    @Autowired
    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void sendVerificationEmail(String to, String pin) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("EcoRoute Email Verification");
        message.setText("Welcome to EcoRoute! \n\nYour email verification PIN is: " + pin + "\n\nThis code will expire in 10 minutes.");

        mailSender.send(message);
    }

    public void sendPasswordResetEmail(String to, String pin) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("EcoRoute Password Reset");
        message.setText("Your password reset PIN is: " + pin + "\n\nThis code will expire in 10 minutes.");

        mailSender.send(message);
    }
}

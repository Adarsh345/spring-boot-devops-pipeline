package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;

@RestController
public class DemoController {

    @GetMapping("/api/status")
    public Map<String, String> getStatus() {
        return Map.of("status", "UP", "message", "System is running");
    }

    @GetMapping("/api/hello")
    public String sayHello() {
        return "Hello from Production-Ready GKE!";
    }
}
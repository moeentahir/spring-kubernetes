package org.ss.demo.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.ss.demo.entities.User;
import org.ss.demo.services.UserService;

@Controller
@RequestMapping(path = "/user")
public class UserController {
    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping(path = "/add") // Map ONLY POST Requests
    public @ResponseBody
    boolean addNewUser(@RequestParam String name, @RequestParam String email) {

        User n = new User();
        n.setName(name);
        n.setEmail(email);
        User savedUser = userService.save(n);

        return savedUser != null;
    }

    @GetMapping(path = "/all")
    public @ResponseBody
    Iterable<User> getAllUsers() {
        return userService.findAll();
    }

    @GetMapping(path = "/find")
    public @ResponseBody
    User getUser(@RequestParam String email) {
        return userService.findByEmail(email);
    }
}

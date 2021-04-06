package org.ss.demo.controllers;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.ss.demo.entities.User;
import org.ss.demo.services.UserService;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UserControllerTest {

    @Test
    void addNewUser_whenUserIsProvided_shouldCallServiceSaver() {

        UserService userServiceMock = mock(UserService.class);

        when(userServiceMock.save(any(User.class))).thenReturn(new User());

        UserController userController = new UserController(userServiceMock);

        boolean actual = userController.addNewUser("Moeen", "moeentahir@gmail.com");

        assertTrue(actual);
        verify(userServiceMock, times(1)).save(any(User.class));
        Mockito.verifyNoMoreInteractions(userServiceMock);
    }
}
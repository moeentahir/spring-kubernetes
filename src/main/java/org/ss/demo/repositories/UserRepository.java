package org.ss.demo.repositories;

import org.springframework.data.repository.CrudRepository;
import org.ss.demo.entities.User;


public interface UserRepository extends CrudRepository<User, Integer> {
    public User findByEmail(String email);
}

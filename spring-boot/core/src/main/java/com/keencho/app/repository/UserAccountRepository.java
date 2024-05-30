package com.keencho.app.repository;

import com.keencho.app.model.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserAccountRepository extends JpaRepository<UserAccount, String> {
    UserAccount findByLoginId(String loginId);
}

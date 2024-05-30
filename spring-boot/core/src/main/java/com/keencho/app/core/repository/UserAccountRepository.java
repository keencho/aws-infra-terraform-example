package com.keencho.app.core.repository;

import com.keencho.app.core.model.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserAccountRepository extends JpaRepository<UserAccount, String> {
    UserAccount findByLoginId(String loginId);
}

package com.keencho.app.repository;

import com.keencho.app.model.AdminAccount;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdminAccountRepository extends JpaRepository<AdminAccount, String> {
    AdminAccount findByLoginId(String loginId);
}

package com.keencho.app.core.repository;

import com.keencho.app.core.model.AdminAccount;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdminAccountRepository extends JpaRepository<AdminAccount, String> {
    AdminAccount findByLoginId(String loginId);
}

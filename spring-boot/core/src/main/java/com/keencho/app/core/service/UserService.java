package com.keencho.app.core.service;

import com.keencho.app.core.model.UserAccount;
import com.keencho.app.core.repository.UserAccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class UserService implements AccountService<UserAccount> {

    @Autowired
    UserAccountRepository repository;

    @Transactional(readOnly = true)
    public List<UserAccount> listAll() {
        return repository.findAll();
    }

    @Override
    public void save(String loginId, String password, String name) {

        if (repository.findByLoginId(loginId) != null) {
            throw new RuntimeException("다른 아이디를 입력해 주세요.");
        }

        var account = new UserAccount();
        account.setLoginId(loginId);
        account.setPassword(password);
        account.setName(name);
        account.setCreatedAt(LocalDateTime.now());

        repository.save(account);
    }

    @Override
    public void delete(String loginId) {
        repository.delete(repository.findByLoginId(loginId));
    }


}

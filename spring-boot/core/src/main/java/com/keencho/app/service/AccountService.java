package com.keencho.app.service;

import java.util.List;

public interface AccountService<T> {
    List<T> listAll();

    void save(String loginId, String password, String name);

    void delete(String loginId);
}

package com.keencho.app.core.controller;

import com.keencho.app.core.service.UserService;
import com.keencho.app.core.service.AccountService;
import com.keencho.app.core.service.AdminService;
import com.keencho.app.core.utils.Env;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/account")
public class AccountController {

    @Autowired
    Env env;

    @Autowired
    AdminService adminService;

    @Autowired
    UserService userService;

    @GetMapping
    public List<?> listAll() {
        return getService().listAll();
    }

    @PostMapping
    public void save(@RequestBody Map<String, String> data) {
        getService().save(data.get("loginId"), data.get("password"), data.get("name"));
    }

    @DeleteMapping
    public void delete(@RequestBody Map<String, String> data) {
        getService().delete(data.get("loginId"));
    }

    private AccountService<?> getService() {
        return env.appType == Env.AppType.ADMIN ? adminService : userService;
    }
}

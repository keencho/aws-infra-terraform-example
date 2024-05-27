package com.keencho.app;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class Controller {

    @Autowired
    Env env;

    @GetMapping("/test")
    public Object test() {
        return Map.of("appType", env.appType);
    }
}

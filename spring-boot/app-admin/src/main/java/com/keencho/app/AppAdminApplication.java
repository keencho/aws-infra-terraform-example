package com.keencho.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;

@SpringBootApplication
public class AppAdminApplication {

    public static void main(String[] args) {
        SpringApplication.run(AppAdminApplication.class, args);
    }

    @Bean
    public Env env(Environment env) {
        return new Env(env, Env.AppType.ADMIN);
    }

}

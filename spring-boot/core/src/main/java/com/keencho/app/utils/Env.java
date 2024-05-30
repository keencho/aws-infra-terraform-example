package com.keencho.app.utils;

import org.springframework.core.env.Environment;

import java.util.Arrays;
import java.util.stream.Collectors;

public class Env {

    public enum AppType { ADMIN, USER }

    public AppType appType;
    public boolean isTest = false;
    public boolean isProd = false;
    public boolean isLocal = false;

    public Env(Environment env, AppType appType) {
        var profiles = env.getActiveProfiles();
        if (profiles.length == 0) {
            throw new RuntimeException("The application cannot be started because there is no active profile. Check the active profile.");
        }

        this.appType = appType;
        var vmList = Arrays.stream(profiles).collect(Collectors.toSet());

        for (var vm : vmList) {
            if (vm.contains("local")) {
                isLocal = true;
            }

            if (vm.contains("test")) {
                isTest = true;
            }

            if (vm.contains("prod")) {
                isProd = true;
            }
        }
    }

}

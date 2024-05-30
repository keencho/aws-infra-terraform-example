package com.keencho.app.core.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "ADMIN_ACCOUNT")
public class AdminAccount {

    @Id
    @GeneratedValue(strategy= GenerationType.AUTO)
    private Long id;

    private String loginId;

    private String password;

    private String name;

    private LocalDateTime createdAt;

}

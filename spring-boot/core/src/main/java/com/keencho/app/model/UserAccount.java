package com.keencho.app.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "USER_ACCOUNT")
public class UserAccount {

    @Id
    @GeneratedValue(strategy= GenerationType.AUTO)
    private Long id;

    private String loginId;

    private String password;

    private String name;

    private LocalDateTime createdAt;

}

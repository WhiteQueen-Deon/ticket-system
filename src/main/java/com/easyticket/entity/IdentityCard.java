package com.easyticket.entity;

import javax.persistence.*;

@Entity
public class IdentityCard {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String number; // 身份证号

    @OneToOne(mappedBy = "card") // 被 User 所映射
    private User user;

    public IdentityCard() {}

    public IdentityCard(String number) {
        this.number = number;
    }

    public Long getId() {
        return id;
    }

    public String getNumber() {
        return number;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}

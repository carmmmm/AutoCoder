package com.Demo.DemoApplication.Model;

public class UserInfo {

    //Declare fields as required
    private String name;

    public UserInfo(){}

    public UserInfo(String username) {
        this.name = username;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "User{" +
                "Username='" + name + '\'' +
                '}';
    }
}

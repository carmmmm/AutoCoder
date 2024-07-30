package com.Demo.DemoApplication.Model;

public class UserResponse {

    //Response class to return appropriate responses
    private String message;

    public UserResponse(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}

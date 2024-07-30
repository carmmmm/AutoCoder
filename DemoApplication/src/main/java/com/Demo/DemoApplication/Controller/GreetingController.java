package com.Demo.DemoApplication.Controller;

import com.Demo.DemoApplication.Model.UserInfo;
import com.Demo.DemoApplication.Model.UserResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class GreetingController {

    //get end point
    //to call, use the below endpoint url
    //http://localhost:7070/api/hello
    @GetMapping("/hello")
    public String getHello(){
        return "Hello Welcome to Spring Boot, Have a nice day !!";
    }

    //post end point
    //to call, use the below endpoint url
    //http://localhost:7070/api/greet
    @PostMapping("/greet")
    public ResponseEntity<UserResponse> greeting(@RequestBody UserInfo user){
        String name=user.getName();
        if(name==null||name.isEmpty()){
            return new ResponseEntity<>(new UserResponse("Name is required and cannot be Empty !!"),HttpStatus.BAD_REQUEST);
        }else {
            String message = "Hello " + name + " how you doing !";
            UserResponse userResponse = new UserResponse(message);
            return ResponseEntity.ok(userResponse);
        }
    }
}

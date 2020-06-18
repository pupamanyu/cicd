package com.example;

import com.example.Greetings;
import org.apache.commons.lang3.StringUtils;

public class App1 {

    public static void main(String ... args) {
        Greetings greetings = new Greetings();

        System.out.println(greetings.greet("Bazel"));

        System.out.println(StringUtils.lowerCase("Bazel"));
    }
}

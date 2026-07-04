package com.devops.lab7;

/**
 * Main class — entry point for the CI demo application
 */
public class Main {
    public static void main(String[] args) {
        Calculator calc = new Calculator();

        System.out.println("=== DevOps Lab 7 — CI Pipeline Demo ===");
        System.out.println("Calculator is running...");

        int a = 10, b = 5;
        System.out.printf("%d + %d = %d%n", a, b, calc.add(a, b));
        System.out.printf("%d - %d = %d%n", a, b, calc.subtract(a, b));
        System.out.printf("%d * %d = %d%n", a, b, calc.multiply(a, b));
        System.out.printf("%d / %d = %.1f%n", a, b, calc.divide(a, b));

        System.out.println("CI Pipeline integration successful!");
    }
}

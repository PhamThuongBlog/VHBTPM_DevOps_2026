package com.devops.lab7;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit Tests for Calculator — runs in CI Pipeline
 * Lab 7 — DevOps Course
 */
class CalculatorTest {

    private Calculator calc;

    @BeforeEach
    void setUp() {
        calc = new Calculator();
    }

    @Test
    @DisplayName("Test addition: 2 + 3 = 5")
    void testAdd() {
        assertEquals(5, calc.add(2, 3));
        assertEquals(0, calc.add(-1, 1));
        assertEquals(-5, calc.add(-2, -3));
    }

    @Test
    @DisplayName("Test subtraction: 3 - 2 = 1")
    void testSubtract() {
        assertEquals(1, calc.subtract(3, 2));
        assertEquals(-2, calc.subtract(1, 3));
    }

    @Test
    @DisplayName("Test multiplication: 2 * 3 = 6")
    void testMultiply() {
        assertEquals(6, calc.multiply(2, 3));
        assertEquals(0, calc.multiply(5, 0));
        assertEquals(-10, calc.multiply(-2, 5));
    }

    @Test
    @DisplayName("Test division: 6 / 3 = 2.0")
    void testDivide() {
        assertEquals(2.0, calc.divide(6, 3));
        assertEquals(1.5, calc.divide(3, 2));
    }

    @Test
    @DisplayName("Test division by zero throws exception")
    void testDivideByZero() {
        assertThrows(IllegalArgumentException.class, () -> calc.divide(5, 0));
    }

    @Test
    @DisplayName("Test isPositive: 5 is positive, -1 is not")
    void testIsPositive() {
        assertTrue(calc.isPositive(5));
        assertFalse(calc.isPositive(-1));
        assertFalse(calc.isPositive(0));
    }
}

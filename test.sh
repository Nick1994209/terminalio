#!/bin/bash

# Test script for TerminalIO application

echo "Running all TerminalIO tests..."

# Run all tests
go test ./tests/... -v

echo "Test execution completed."
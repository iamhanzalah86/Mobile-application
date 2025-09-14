
import 'dart:io';

void main() {
  //runApp(const MyApp());

  // Step 1: Take input for name and age
  print("Enter your name: ");
  String name = stdin.readLineSync()!;

  print("Enter your age: ");
  int age = int.parse(stdin.readLineSync()!);

  if (age < 18) {
    print("Sorry $name, you are not eligible to register.");
    return; // stop execution
  }

  // Step 2: Ask how many numbers
  print("How many numbers do you want to enter? ");
  int n = int.parse(stdin.readLineSync()!);

  // Step 3: Input numbers into a list
  List<int> numbers = [];
  for (int i = 0; i < n; i++) {
    print("Enter number ${i + 1}: ");
    int num = int.parse(stdin.readLineSync()!);
    numbers.add(num);
  }

  // Step 4: Initialize variables for calculations
  int evenSum = 0;
  int oddSum = 0;
  int largest = numbers[0];
  int smallest = numbers[0];

  // Loop through numbers for calculations
  for (int num in numbers) {
    if (num % 2 == 0) {
      evenSum += num;
    } else {
      oddSum += num;
    }

    if (num > largest) {
      largest = num;
    }
    if (num < smallest) {
      smallest = num;
    }
  }

  // Step 5: Print results clearly
  print("\n--- Results ---");
  print("Numbers entered: $numbers");
  print("Sum of even numbers: $evenSum");
  print("Sum of odd numbers: $oddSum");
  print("Largest number: $largest");
  print("Smallest number: $smallest");
}
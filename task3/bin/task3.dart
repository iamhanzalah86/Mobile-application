import 'dart:io';

void main() {
  print("Enter a number: ");
  int? n = int.parse(stdin.readLineSync()!);

  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= i; j++) {
      print("$j ");
    }
    print(""); // move to next line
  }
}

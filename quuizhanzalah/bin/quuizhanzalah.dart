import 'package:quuizhanzalah/quuizhanzalah.dart' as quuizhanzalah;
import 'dart:io';
void main() {
  int n=6;
  List<int> numbers = [];
  for (int i = 0; i < n; i++) {
    print("Enter number ${i + 1}: ");
    int num = int.parse(stdin.readLineSync()!);
    numbers.add(num);
  }
  int smallest=9999999;
  int sum = 0;
for(int n =0; n<6; n++) {
  int num = numbers[n];
  if(num%2==1){
    sum +=num;
  }
  if (num < smallest) {
    smallest = num;
  }
}
print("smallest number");
print(smallest);
print("odd number sum");
print(sum);

}

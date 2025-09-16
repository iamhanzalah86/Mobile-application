import 'package:quizsaib/quizsaib.dart' as quizsaib;
import 'dart:io';
void main(List<String> arguments) {
  List<int> numbers= [];
  int smallest=99999;
  int sum=0;
  for(int i=0;i<6;i++){
    print("Enter number ${i + 1}: ");
    int num = int.parse(stdin.readLineSync()!);
    numbers.add(num);
    if(numbers[i]%2>0){
      sum+=numbers[i];
    }
    if (smallest>numbers[i]){
      smallest=numbers[i];
    }
  }
  print("sum=");
  print(sum);
  print("smallest=");
  print(smallest);

}

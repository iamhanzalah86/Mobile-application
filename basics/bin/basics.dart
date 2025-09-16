import 'dart:io';
class Student{
  String display="class";
  Student(){
    display="const";
    print(display);
  }
  Student.parameterized(this.display){
    display="paraconst";
    print(display);  }
  Student.named(required String name){
    display=name;
    print(display);
  }
  Student().young : this.parameterized("redconst");

  const Student.constant(this.display){
    display="constconst";
    print(display);
  }

}
void main() {

}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:mvvm_practice/data/app_exceptions.dart';
import 'package:mvvm_practice/data/network/baseapi.dart';
import 'package:http/http.dart' as http;
class NetworkApi extends baseapi {
  @override

  Future getGetApiResponse(String url) async {
    dynamic responseJson;
    try{
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      responseJson=   returnResponse(response);
    }on SocketException{
      throw FetchDataException("NO Internet");
    }

  }

  @override
  Future getPostApiResponse(String url, dynamic data) async {
    dynamic responseJson ;
    try{
      Response response = await post(
        Uri.parse(url),
        body:data
      ).timeout(Duration(seconds: 10));

      responseJson=   returnResponse(response);
    }on SocketException{
      throw FetchDataException("NO Internet");
    }
    return responseJson;
  }


  dynamic returnResponse (http.Response response){

   switch(response.statusCode){
     case 200:
       dynamic responseJson = jsonDecode(response.body);
       return responseJson;
     case 400:
       throw BadRequestException(response.body.toString());

     default:
       throw FetchDataException("error occured while communicating with server"+"with status code"+response.statusCode.toString());

   }
  }
}
import 'package:mvvm_practice/data/network/baseapi.dart';
import 'package:mvvm_practice/data/network/NetworkApi.dart';
import 'package:mvvm_practice/res/components/app_url.dart';

class AuthRepository {
  baseapi _apiSservices = NetworkApi();
   Future<dynamic> loginApi(dynamic data)async{

     try{
     dynamic response = await _apiSservices.getPostApiResponse(AppUrl.loginEndpoint, data);
     return response;
     }catch(e){
        throw e;
     }
   }
}
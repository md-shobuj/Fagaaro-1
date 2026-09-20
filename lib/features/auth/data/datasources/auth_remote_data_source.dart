import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_response.dart';
import '../models/user_model.dart';
import '../models/user_profile_model.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class AuthRemoteDataSource {
  @factoryMethod
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @POST('/auth/login')
  Future<ApiResponse<UserModel>> login(@Body() Map<String, dynamic> body);

  @POST('/auth/register')
  Future<ApiResponse<UserModel>> register(@Body() Map<String, dynamic> body);

  @GET('/me')
  Future<ApiResponse<UserProfileModel>> getUserProfile();

  @POST('/auth/logout')
  Future<void> logout();
}

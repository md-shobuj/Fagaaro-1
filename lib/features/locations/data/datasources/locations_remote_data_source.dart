import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/network/api_response.dart';
import '../models/geofence_location_model.dart';

part 'locations_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class LocationsRemoteDataSource {
  @factoryMethod
  factory LocationsRemoteDataSource(Dio dio) = _LocationsRemoteDataSource;

  @GET('/locations')
  Future<ApiResponse<List<GeofenceLocationModel>>> getLocations();

  @POST('/locations')
  Future<ApiResponse<GeofenceLocationModel>> createLocation(@Body() Map<String, dynamic> body);

  @PUT('/locations/{id}')
  Future<ApiResponse<GeofenceLocationModel>> updateLocation(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/locations/{id}')
  Future<void> deleteLocation(@Path('id') String id);
}

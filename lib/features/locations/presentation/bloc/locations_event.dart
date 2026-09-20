import 'package:equatable/equatable.dart';
import '../../domain/entities/geofence_location.dart';

abstract class LocationsEvent extends Equatable {
  const LocationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocationsEvent extends LocationsEvent {}

class AddLocationEvent extends LocationsEvent {
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;

  const AddLocationEvent({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [name, latitude, longitude, radius, isActive];
}

class UpdateLocationEvent extends LocationsEvent {
  final GeofenceLocation location;

  const UpdateLocationEvent({
    required this.location,
  });

  @override
  List<Object?> get props => [location];
}

class DeleteLocationEvent extends LocationsEvent {
  final String id;

  const DeleteLocationEvent({
    required this.id,
  });

  @override
  List<Object?> get props => [id];
}

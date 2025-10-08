import 'package:equatable/equatable.dart';
import '../../../data/models/conversion_response.dart';

abstract class ConversionState extends Equatable {
  const ConversionState();

  @override
  List<Object?> get props => [];
}

class ConversionInitial extends ConversionState {}

class ConversionLoading extends ConversionState {}

class ConversionSuccess extends ConversionState {
  final ConversionResponse response;
  final List<String> recentPairs;

  const ConversionSuccess({
    required this.response,
    this.recentPairs = const [],
  });

  @override
  List<Object?> get props => [response, recentPairs];
}

class ConversionError extends ConversionState {
  final String message;

  const ConversionError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConversionWithRecent extends ConversionState {
  final List<String> recentPairs;

  const ConversionWithRecent(this.recentPairs);

  @override
  List<Object?> get props => [recentPairs];
}
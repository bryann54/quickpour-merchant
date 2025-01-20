part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAnalyticsData extends AnalyticsEvent {}

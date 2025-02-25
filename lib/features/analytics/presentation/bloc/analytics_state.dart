part of 'analytics_bloc.dart';

abstract class AnalyticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final int stockCount;
  // final int ordersCount;
  // final int feedbackCount;

  AnalyticsLoaded({
    required this.stockCount,
    // required this.ordersCount,
    // required this.feedbackCount,
  });

  @override
  List<Object?> get props => [
        stockCount,
        //  ordersCount, feedbackCount
      ];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}

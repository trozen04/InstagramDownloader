part of 'insta_downloader_bloc.dart';

@immutable
sealed class InstaDownloaderState {}

final class InstaDownloaderInitial extends InstaDownloaderState {}

class InstaDownloaderLoadingState extends InstaDownloaderState {}

class InstaDownloaderSuccessState extends InstaDownloaderState {
  dynamic responseData;
  InstaDownloaderSuccessState(this.responseData);
}

class InstaDownloaderErrorState extends InstaDownloaderState {
  final String errorMessage;
  InstaDownloaderErrorState(this.errorMessage);
} 


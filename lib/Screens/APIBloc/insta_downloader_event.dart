part of 'insta_downloader_bloc.dart';

@immutable
sealed class InstaDownloaderEvent {}

class InstaDownloaderEventHandler extends InstaDownloaderEvent {
  String url;
  InstaDownloaderEventHandler({required this.url});
}


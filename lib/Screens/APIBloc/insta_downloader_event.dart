part of 'insta_downloader_bloc.dart';

@immutable
sealed class InstaDownloaderEvent {}

class InstaDownloaderEventHandler extends InstaDownloaderEvent {
  String url;
  String? type;
  InstaDownloaderEventHandler({required this.url, this.type});
}


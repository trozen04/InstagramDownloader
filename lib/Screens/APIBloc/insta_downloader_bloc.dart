import 'dart:convert';
import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:instagram_downloader_project/Utils/constants.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'insta_downloader_event.dart';
part 'insta_downloader_state.dart';

class InstaDownloaderBloc extends Bloc<InstaDownloaderEvent, InstaDownloaderState> {
  InstaDownloaderBloc() : super(InstaDownloaderInitial()) {

    on<InstaDownloaderEventHandler>((event, emit) async {
      emit(InstaDownloaderLoadingState());
      try {

        final String avatarKey = ApiConstants.xAvatarKey;

        const validTypes = [
          'instagram',
          'youtube',
          'linkedin',
          'facebook',
          'twitter',
          'twitter_metadata',
          'insta_story',
          'insta_highlight',
          'profile_pic',
          'pinterest',
          'snapchat'
        ];
        if (!validTypes.contains(event.type)) {
          emit(InstaDownloaderErrorState('Invalid platform type: ${event.type}'));
          return;
        }

        final Map<String, dynamic> body = {
          'video_url': event.url,
          'type': event.type,
        };

        if (['insta_story', 'insta_highlight', 'profile_pic', 'intagram'].contains(event.type)) {
          body['user_id'] = 'ig_trozen';
        }

        if (event.type == 'youtube') {
          body['get_url'] = true;
        }

        final response = await http.post(
          Uri.parse(ApiConstants.baseUrl),
          headers: {
            "Content-Type": "application/json",
            "X-Avatar-Key": avatarKey,
          },
          body: jsonEncode(body),
        );

        final responseBody = jsonDecode(response.body);
        if(response.statusCode == 200 || response.statusCode == 201) {
          print('event: ${event.type}');
          if (responseBody == null) {
            emit(InstaDownloaderErrorState('No data returned from the server.'));
            return;
          }
          if (event.type == 'youtube') {
            emit(InstaDownloaderSuccessState(responseBody));
            return;
          }
          final resultData = responseBody['data'];
          emit(InstaDownloaderSuccessState(resultData));
        } else {
          final responseMessage = responseBody['message'];
          emit(InstaDownloaderErrorState(responseMessage));
        }
      } catch (e){
        emit(InstaDownloaderErrorState('Something error occurred.'));
      }
    });
  }
}

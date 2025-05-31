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

        final String avatarKey = "454739b9-415f-493f-bc7c-e64f62bf1f13";

        final Map<String, dynamic> body = {
          "video_url": event.url,
          "type": event.type,
          "user_id": "trozen"
        };

        developer.log('Sending request to ${ApiConstants.baseUrl}');
        developer.log('body: ${body}');

        final response = await http.post(
          Uri.parse(ApiConstants.baseUrl),
          headers: {
            "Content-Type": "application/json",
            "X-Avatar-Key": avatarKey,
          },
          body: jsonEncode(body),
        );

        developer.log('response code: ${response.statusCode}');
        developer.log('response: ${response.body}');
        final responseBody = jsonDecode(response.body);
        if(response.statusCode == 200 || response.statusCode == 201) {
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

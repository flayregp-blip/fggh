import 'dart:convert';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/file_path_model.dart';
import 'package:shortzz/model/general/location_place_model.dart';
import 'package:shortzz/model/general/place_detail.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/utilities/app_res.dart';

class CommonService {
  CommonService._();
  static final CommonService instance = CommonService._();

  Future<bool> fetchGlobalSettings() async {
    SettingModel settingsModel = await ApiService.instance.call(
        url: WebService.setting.fetchSettings,
        fromJson: SettingModel.fromJson,
        cancelAuthToken: true);
    var setting = settingsModel.data;
    if (setting != null) {
      SessionManager.instance.setSettings(setting);
      return true;
    }
    return false;
  }

  Future<FilePathModel> uploadFileGivePath(XFile files,
      {Function(double percentage)? onProgress}) async {
    FilePathModel model = await ApiService.instance.multiPartCallApi(
      url: WebService.setting.uploadFileGivePath,
      filesMap: {
        Params.file: [files]
      },
      onProgress: onProgress,
      fromJson: FilePathModel.fromJson,
    );
    return model;
  }

  Future<StatusModel> deleteFile(String filePath) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.setting.deleteFile,
        param: {Params.filePath: filePath},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<Places>> searchPlace({String title = ''}) async {
    if (title.trim().isEmpty) return [];
    Uri uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(title)}&format=json&addressdetails=1&limit=${AppRes.paginationLimit}',
    );
    Map<String, String> header = {
      'User-Agent': 'FlayrApp/1.0',
      'Accept-Language': 'ar,en',
    };
    Loggers.info('Nominatim search: $uri');
    Response response = await get(uri, headers: header);
    List<dynamic> jsonList = jsonDecode(response.body);
    List<Places> places = jsonList.map((e) => Places.fromNominatim(e as Map<String, dynamic>)).toList();
    Loggers.success('Found ${places.length} places');
    return places;
  }

  Future<List<Places>> searchNearBy(
      {required double lat, required double lon}) async {
    Uri uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1&zoom=14',
    );
    Map<String, String> header = {
      'User-Agent': 'FlayrApp/1.0',
      'Accept-Language': 'ar,en',
    };
    Loggers.info('Nominatim nearby: $uri');
    Response response = await get(uri, headers: header);
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    Places place = Places.fromNominatim(jsonMap);
    Loggers.success('Found nearby place: ${place.title}');
    return [place];
  }

  Future<PlaceDetail> getIPPlaceDetail() async {
    Map<String, dynamic> detail =
        await ApiService.instance.callGet(url: WebService.common.ipApi);
    return PlaceDetail.fromJson(detail);
  }
}

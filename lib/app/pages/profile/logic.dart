import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediaverse/app/common/RequestInterface.dart';
import 'package:mediaverse/app/common/app_api.dart';
import 'package:mediaverse/app/common/app_config.dart';
import 'package:mediaverse/app/pages/wrapper/logic.dart';
import 'package:mediaverse/gen/model/json/FromJsonGetAllAsstes.dart';
import 'package:mediaverse/gen/model/json/FromJsonGetAssets.dart';
import 'package:mediaverse/gen/model/json/FromJsonGetProfile.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../gen/model/json/FromJsonGetImages.dart';
import '../../../gen/model/json/FromJsonGetWallet.dart';
import '../../common/app_color.dart';
import 'package:dio/dio.dart' as d;

import '../../common/utils/dio_inperactor.dart';

class ProfileControllers extends GetxController implements RequestInterface {
  final _obj = ''.obs;

  set obj(value) => _obj.value = value;
  WalletModel walletModel = WalletModel();

  get obj => _obj.value;

  late FromJsonGetImages fromJsonGetImages;
  ProfileModel model = ProfileModel();
  late ApiRequster apiRequster;

  List<dynamic> ownerImages = [];
  List<dynamic> ownerVideos = [];
  List<dynamic> ownerAudios = [];
  List<dynamic> ownerText = [];

  List<dynamic> subImages = [];
  List<dynamic> subVideos = [];
  List<dynamic> subAudios = [];
  List<dynamic> subText = [];

  bool emptySubAll = false;
  bool emptySubImages = false;
  bool emptySubVideos = false;
  bool emptySubAudios = false;
  bool emptySubText = false;

  var isStripeConnected = true;


  FromJsonGetAllAsstes myAssets = FromJsonGetAllAsstes();
  FromJsonGetAllAsstes mysubsAssets = FromJsonGetAllAsstes();
  late AssetsModel assetsModel;
  var isassetInit = false.obs;
  var isloading = false.obs;

  var isloading1 = false.obs;
  var isloading2 = false.obs;
  var isloading3 = false.obs;
  var isloading4 = false.obs;
  var isloading5 = false.obs;
  var isloading6 = false.obs;
  var isloading7 = false.obs;
  var isloading8 = false.obs;
  var isloading9 = false.obs;
  var isloadingWallet = false.obs;
  var isloadingEdit = false.obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    apiRequster = ApiRequster(this, develperModel: false);

    onGetProfileMethod();
    getWalletBalance();
    getStripe();
  }

  onGetProfileMethod() {
    isloading(true);
    apiRequster.request("profile", ApiRequster.MHETOD_GET, 1, useToken: true);
  }

  @override
  void onError(String content, int reqCode, bodyError) {
    // TODO: implement onError
    if(reqCode==15){
      isStripeConnected = false;
      update();
      //getStripeConnect();
    }else{
      print('ProfileControllers.onError = ${content}');
      try {
        var messege = jsonDecode(bodyError)['message'];
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(messege,
          style: TextStyle(color: AppColor.primaryDarkColor),)));
      }  catch (e) {
        // TODO
      }
      var messege = jsonDecode(content)['message'];
      print('ProfileControllers.onError 2  =${messege}');
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 3.h),
          content: Text(messege,
        style: TextStyle(color: AppColor.primaryDarkColor),)));

    }
  }

  @override
  void onStartReuqest(int reqCode) {
    // TODO: implement onStartReuqest
  }

  @override
  void onSucces(source, int reqCdoe) {
    // TODO: implement onSucces
    switch (reqCdoe) {
      case 1:
        praseJsonFromGetProfile(source);
        break;
      case 2:
        praseJsonFromGetAssets(source);
        break;
      case 3:
        praseJsonFromGetAllMyAssets(source);
        break;
      case 4:
        parseJsonFromGetAllImages(source);
        break;
      case 5:
        parseJsonFromGetAllVideos(source);
        break;
      case 6:
        parseJsonFromGetAllAudios(source);
        break;
      case 7:
        parseJsonFromGetAllTexts(source);
        break;
      case 8:
        parseJsonFromGetSubsAll(source);
        break;
      case 9:
        parseJsonFromGetSubsImages(source);
        break;
      case 10:
        parseJsonFromGetSubsVideos(source);
        break;
      case 11:
        parseJsonFromGetSubsAudios(source);
        break;
      case 12:
        parseJsonFromGetSubsTexts(source);
        break;
       case 13:
        parseJsonFromEditText(source);
        break;
       case 14:
        parseJsonFromGetWalletBalance(source);
        break;
       case 15:
        pareJsonFromStripe(source);
        break;
       case 16:
        pareJsonFromStripeConnect(source);
        break;
        case 17:
        parseJsonFromGateWay(source);
        break;
    }
  }

  void praseJsonFromGetProfile(source) {
   // print('ProfileControllers.praseJsonFromGetProfile  1 ${source}');
    model = ProfileModel.fromJson(jsonDecode(source));
  //  print('ProfileControllers.praseJsonFromGetProfile  2 ');
    onGetProfileAssets();

    onGetAssetsAll();
    onGetSubsAssetsAll();
  }

  onGetProfileAssets() {
    isloading(true);
    apiRequster.request("profile/statics", ApiRequster.MHETOD_GET, 2,
        useToken: true);
  }

  onGetAssetsAll() {
    //print('ProfileControllers.onGetAssetsAll 1 ');
    isloading1(true);
    apiRequster.request("profile/assets", ApiRequster.MHETOD_GET, 3,
        useToken: true);
  }

  onGetAssetsPhoto() {
    isloading1(true);
    apiRequster.request("profile/images", ApiRequster.MHETOD_GET, 4,
        useToken: true);
  }

  onGetAssetsVideo() {
    isloading2(true);
    apiRequster.request("profile/videos", ApiRequster.MHETOD_GET, 5,
        useToken: true);
  }

  onGetAssetsAudioes() {
    isloading3(true);
    apiRequster.request("profile/audios", ApiRequster.MHETOD_GET, 6,
        useToken: true);
  }

  onGetAssetsText() {
    isloading4(true);
    apiRequster.request("profile/texts", ApiRequster.MHETOD_GET, 7,
        useToken: true);
  }

  onGetSubsAssetsPhoto() {
    isloading6(true);
    apiRequster.request("profile/subscriptions/images", ApiRequster.MHETOD_GET, 9,
        useToken: true);
  }

  onGetSubsAssetsVideo() {
    isloading7(true);
    apiRequster.request("profile/subscriptions/videos", ApiRequster.MHETOD_GET, 10,
        useToken: true);
  }

  onGetSubsAssetsAudioes() {
    isloading8(true);
    apiRequster.request("profile/subscriptions/audios", ApiRequster.MHETOD_GET, 11,
        useToken: true);
  }

  onGetSubsAssetsText() {
    isloading9(true);
    apiRequster.request("profile/subscriptions/texts", ApiRequster.MHETOD_GET, 12,
        useToken: true);
  }

  onGetSubsAssetsAll() {
   // print('ProfileControllers.onGetAssetsAll 2 ');

    isloading5(true);
    apiRequster.request("profile/subscriptions", ApiRequster.MHETOD_GET, 8,
        useToken: true);
  }

  void praseJsonFromGetAssets(source) {
    assetsModel = AssetsModel.fromJson(jsonDecode(source));
    isloading(false);
    isassetInit(true);
    update();
  }

  void praseJsonFromGetAllMyAssets(source) {
    myAssets = FromJsonGetAllAsstes.fromJson(jsonDecode(source));
    update();
  }

  void parseJsonFromGetAllImages(source) {
    ownerImages = FromJsonGetImages.fromJson(jsonDecode(source)).data ?? [];

    isloading1(false);
  }

  void parseJsonFromGetAllVideos(source) {
    ownerVideos = FromJsonGetImages.fromJson(jsonDecode(source)).data ?? [];

    isloading2(false);
  }

  void parseJsonFromGetAllAudios(source) {
    ownerAudios = FromJsonGetImages.fromJson(jsonDecode(source)).data ?? [];

    isloading3(false);
  }

  void parseJsonFromGetAllTexts(source) {
    ownerText = FromJsonGetImages.fromJson(jsonDecode(source)).data ?? [];

    isloading4(false);
  }

  void parseJsonFromGetSubsAll(source) {
    mysubsAssets = FromJsonGetAllAsstes.fromJson(jsonDecode(source));
    isloading5(false);
    print('ProfileControllers.parseJsonFromGetSubsAll = ${mysubsAssets.all!.length}');

    if((mysubsAssets.all??[]).isEmpty)emptySubAll=true;
    update();
  }

  void parseJsonFromGetSubsImages(source) {
    print('ProfileControllers.parseJsonFromGetSubsImages = ${source}');
    subImages = FromJsonGetImages.fromJson(jsonDecode(source)).data ?? [];

    if (subImages.isEmpty) emptySubImages = true;
    isloading6(false);
  }

  void parseJsonFromGetSubsVideos(source) {

    subVideos = FromJsonGetImages.fromJson(jsonDecode(source)).data ?? [];

    if (subVideos.isEmpty) emptySubVideos = true;
    isloading7(false);
  }

  void parseJsonFromGetSubsAudios(source) {
    subAudios = FromJsonGetImages.fromJson(jsonDecode(source)).data ?? [];

    if (subAudios.isEmpty) emptySubAudios = true;
    isloading8(false);
  }

  void parseJsonFromGetSubsTexts(source) {
    subText = FromJsonGetImages.fromJson(jsonDecode(source)).data ?? [];

    if (subText.isEmpty) emptySubText = true;
    isloading9(false);
  }

  void sendEditRequest(String text, String text2, String text3) {
    isloadingEdit(true);

    var body = {
      "first_name": text,
      "last_name": text2,
      "email": text3,

    };
    apiRequster.request("profile", ApiRequster.MHETOD_PUT, 13,body: body);
  }

  void parseJsonFromEditText(source) {
    isloadingEdit(false);
    Constant.showMessege(" Profile Update Successful ");
  }




  getWalletBalance(){
    isloading(true);
    apiRequster.request("stripe/balance", ApiRequster.MHETOD_GET, 14,useToken: true);
  }

  getStripe(){
    // isloading(true);
    apiRequster.request("stripe/account", ApiRequster.MHETOD_GET, 15,useToken: true);
  }
  getStripeConnect(){
    // isloading(true);
    apiRequster.request("stripe/connect", ApiRequster.MHETOD_POST, 16,useToken: true);
  }
  getStripeGateWay(){
    isloadingWallet(true);
    apiRequster.request("stripe/gateway", ApiRequster.MHETOD_GET, 17,useToken: true);
  }
  void parseJsonFromGetWalletBalance(source) {
   // print('ProfileControllers.parseJsonFromGetWalletBalance = ${source}');
    var balance  =jsonDecode(source)['available'][0]['amount'];

    try{
      Get.find<WrapperController>().walletBalance = balance.toString();
    }catch(r){

    }
    isloading(false);

  }

  void pareJsonFromStripe(source) {
   // print('ProfileControllers.pareJsonFromStripe = ${source}');
    isStripeConnected = true;

    update();

  }

  void pareJsonFromStripeConnect(source) {
    isStripeConnected = true;

    update();
    var url = jsonDecode(source)['url'];

    try {
      launchUrlString(url);
    }  catch (e) {
      // TODO
    }
  }

  void parseJsonFromGateWay(source) {
    isloadingWallet(false);
    log('ProfileControllers.parseJsonFromGateWay = ${source}');

    try {
    var url = jsonDecode(source)['url'];
      launchUrlString(url);
    }  catch (e) {
      // TODO
    }
  }
  final ImagePicker _picker = ImagePicker();


  // Function to pick image and convert it to base64
  Future<void> pickImageAndUpload() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        List<int> imageBytes = await imageFile.readAsBytes();
        uploadFileWithDio(imageFile);
        String base64Image = base64Encode(imageBytes);


        await uploadImage(base64Image);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Function to upload image to server
  Future<void> uploadImage(String base64Image) async {
    try {
      // var response = await http.post(
      //   Uri.parse('YOUR_SERVER_ENDPOINT'),
      //   body: {
      //     'image': base64Image,
      //   },
      // );
      // if (response.statusCode == 200) {
      //   print("Image uploaded successfully");
      // } else {
      //   print("Failed to upload image");
      // }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
  // Function to check and request permission
   checkAndRequestPermission() async {
    pickImageAndUpload();
    // var status = await Permission.photos.status;
    // if (!status.isGranted) {
    //   status = await Permission.photos.request();
    // }
    // return status.isGranted;
  }
  Future<void> uploadFileWithDio(File imageFile) async {
    var dio = Dio();
    var formData = d.FormData.fromMap({
      'image': await d.MultipartFile.fromFile(imageFile.path,
          filename: 'uploadfile'),
    });

    dio.interceptors.add(MediaVerseConvertInterceptor());

    try {
      var response = await dio.put(
        '${Constant.HTTP_HOST}profile',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GetStorage().read("token")}',
            'Content-Type': 'multipart/form-data',
            'X-App': '_Android',
          },
        ),
        onSendProgress: (s, p) {
          //uploadedCount = (s * 100) / p;
          print('PlusSectionLogic.uploadFileWithDio = ${s} - ${p}');
          update();
        },
      );

      if (response.statusCode! >= 200||response.statusCode! < 300) {
        print('==================================================================================================');
        print('File uploaded successfully = ${response.data}');
        print('==================================================================================================');



        //Get.toNamed(_getRouteByMedia(), arguments: {'id': postUploadedId , 'idAssetMedia':'idAssetMedia'});


      } else {
        print('Failed to upload file: ${response.statusMessage}');
      }
    } on DioError catch (e) {
      print('DioError: ${e.message}');
    }
  }

}

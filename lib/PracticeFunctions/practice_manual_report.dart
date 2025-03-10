import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:bcons_app/model/user_model.dart';
import 'package:bcons_app/screens/HomeScreen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class PracticeManual extends StatefulWidget {
  const PracticeManual({Key? key}) : super(key: key);

  @override
  State<PracticeManual> createState() => _PracticeManualState();
}

class _PracticeManualState extends State<PracticeManual> {
  XFile? pickedImage;
  bool isImageLoading = false;
  bool isConfirm = false;
  final ImagePicker picker = ImagePicker();
  String imageUrl = '';
  String reportId = '';

  DateTime initialDate = DateTime.now();
  String pdfURL = '';

  final _formkey = GlobalKey<FormState>();
  final _additionalInfoEditingController = TextEditingController();
  String? emergencyValue;
  final emergencyClass = [
    'Crime',
    'Earthquake',
    'Fire',
    'Flood',
    'Health Emergency',
    'Traffic Accident'
  ];

  DropdownMenuItem<String> buildMenuItem(String emergency) {
    return DropdownMenuItem(
      value: emergency,
      child: Text(
        emergency,
        style: const TextStyle(
            fontFamily: 'PoppinsRegular',
            letterSpacing: 1.5,
            color: Color.fromRGBO(0, 0, 0, 1),
            fontSize: 15.0),
      ),
    );
  }

  imagePickerFromGallery() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = image;
        isImageLoading = true;
      });
    }
  }

  imagePickerFromCamera() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        pickedImage = image;
        isImageLoading = true;
      });
    }
  }

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manual Report',
            style: TextStyle(
                fontFamily: 'PoppinsBold',
                letterSpacing: 2.0,
                color: Colors.white,
                fontSize: 20.0),
          ),
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: const Color(0xffcc021d),
          leading: InkWell(
            child: const Icon(
              Icons.arrow_back,
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Form(
              key: _formkey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isImageLoading
                        ? Center(
                            child: Container(
                                height: 250,
                                width: 250,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    image: DecorationImage(
                                        image:
                                            FileImage(File(pickedImage!.path)),
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high))))
                        : Container(),
                    const SizedBox(height: 20.0),
                    const Text(
                      'What kind of emergency are you going to report?',
                      style: TextStyle(
                          fontFamily: 'PoppinsRegular',
                          letterSpacing: 1.5,
                          color: Colors.black,
                          fontSize: 15.0),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black, width: 1)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                              color: Colors.black,
                            ),
                            value: emergencyValue,
                            isExpanded: true,
                            items: emergencyClass.map(buildMenuItem).toList(),
                            onChanged: (value) {
                              setState(() {
                                emergencyValue = value;
                              });
                            }),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                          fontFamily: 'PoppinsRegular',
                          letterSpacing: 1.5,
                          color: Colors.black,
                          fontSize: 15.0),
                    ),
                    const SizedBox(height: 10.0),
                    textForm(_additionalInfoEditingController,
                        MediaQuery.of(context).size.width, 100)
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor:
                (isImageLoading == true && emergencyValue!.isNotEmpty)
                    ? const Color(0xffd90824)
                    : Colors.grey,
            child: const Text(
              'Done',
              style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  letterSpacing: 1.5,
                  color: Colors.white,
                  fontSize: 15.0),
            ),
            onPressed: (isImageLoading == true && emergencyValue!.isNotEmpty)
                ? () {
                    showSheet();
                  }
                : () {}),
        persistentFooterButtons: [
          Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        imagePickerFromCamera();
                      },
                      icon: Icon(
                        Icons.camera_alt,
                        size: 30,
                      )),
                  SizedBox(
                    width: 15,
                  ),
                  IconButton(
                      onPressed: () {
                        imagePickerFromGallery();
                      },
                      icon: Icon(
                        Icons.image_outlined,
                        size: 30,
                        color: Colors.black,
                      )),
                ],
              ))
        ]);
  }

  uploadImagetoFirebaseStorageAndUploadTheReportDetailsOfUserInDatabase() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    firebase_auth.User? user = firebaseAuth.currentUser;
    FirebaseStorage storageRef = FirebaseStorage.instance;
    String uploadFileName =
        '${loggedInUser.uid},${DateFormat("yyyy-MM-dd,hh:mm:ss").format(initialDate)}.jpg';
    Reference reference =
        storageRef.ref().child('User\'s Report Images').child(uploadFileName);
    UploadTask uploadTask = reference.putFile(File(pickedImage!.path));
    uploadTask.snapshotEvents.listen((event) {
      print(event.bytesTransferred.toString() +
          '\t' +
          event.totalBytes.toString());
    });
    await uploadTask.whenComplete(() async {
      String uploadPath = await uploadTask.snapshot.ref.getDownloadURL();
      print(uploadPath);
      if (uploadPath.isNotEmpty) {
        try {
          String generateRandomString(int length) {
            final _random = Random();
            const _availableChars =
                'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
            final randomString = List.generate(
                length,
                (index) => _availableChars[
                    _random.nextInt(_availableChars.length)]).join();

            return randomString;
          }

          setState(() {
            reportId = generateRandomString(20);
            isConfirm = true;
          });

          //Stored data in realtime database
          DatabaseReference database = FirebaseDatabase.instance
              .ref()
              .child('User\'s Nearby Report')
              .child(user!.uid);
          String? uploadId = database
              .child('User\'s Nearby Report')
              .child(user.uid)
              .push()
              .key;

          HashMap map = HashMap();
          map['email'] = '${loggedInUser.email}';
          map['name'] =
              '${loggedInUser.firstName} ${loggedInUser.middleInitial} ${loggedInUser.lastName}';
          map['age'] = '${loggedInUser.age}';
          map['sex'] = '${loggedInUser.gender}';
          map['date'] = DateFormat("yyyy-MM-dd").format(initialDate);
          map['time'] = DateFormat("hh:mm:ss").format(initialDate);
          map['emergencyTypeOfReport'] = emergencyValue;
          map['description'] = _additionalInfoEditingController.text;
          map['image'] = uploadPath;
          map['latitude'] = loggedInUser.latitude;
          map['longitude'] = loggedInUser.longitude;
          map['address'] = loggedInUser.address;
          map['solvedOrUnsolved'] = 'unsolved';
          database.child(uploadId!).set(map).whenComplete(() {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => const HomeScreen()),
                (route) => false);

            //Upload To Firestore
            firebaseFirestore
                .collection('User\'s Nearby Report')
                .doc(reportId)
                .set({
              'email': '${loggedInUser.email}',
              'uid': '${loggedInUser.uid}',
              'bloodType': '${loggedInUser.bloodType}',
              'status': 'unsolved',
              'autoOrManual': 'manual',
              'name':
                  '${loggedInUser.firstName} ${loggedInUser.middleInitial} ${loggedInUser.lastName}',
              'age': '${loggedInUser.age}',
              'sex': '${loggedInUser.gender}',
              'date': DateFormat("yyyy-MM-dd").format(initialDate),
              'time': DateFormat("hh:mm:ss").format(initialDate),
              'emergencyTypeOfReport': emergencyValue,
              'description': _additionalInfoEditingController.text,
              'image': uploadPath,
              'address': loggedInUser.address,
              'latitude': loggedInUser.latitude,
              'longitude': loggedInUser.longitude,
              'reportId': reportId
            });
          });
          showSnackBar(context, 'Completely Reported');
        } catch (e) {
          showSnackBar(context, e.toString());
        }
      }
    });
  }

  void showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget textForm(
      TextEditingController controller, double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        child: TextFormField(
          autofocus: false,
          controller: controller,
          maxLines: 3,
          textAlign: TextAlign.start,
          onSaved: (value) {
            controller.text = value!;
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            fillColor: Colors.white,
            filled: true,
            hintText: 'Description...',
            hintStyle: const TextStyle(
              fontSize: 15.0,
              color: Colors.grey,
              fontFamily: 'PoppinsRegular',
              letterSpacing: 1.5,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(width: 1, color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(width: 1.0, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Future showSheet() => showSlidingBottomSheet(context,
      builder: (context) => SlidingSheetDialog(
          cornerRadius: 16,
          avoidStatusBar: true,
          snapSpec: const SnapSpec(
            snap: true,
            initialSnap: 0.95,
            snappings: [0.4, 0.7, 0.95],
          ),
          builder: buildSheet,
          headerBuilder: headerBuilder));

  Widget headerBuilder(BuildContext context, SheetState state) {
    return Container(
      color: const Color(0xffcc021d),
      height: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              width: 32,
              height: 8,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget buildSheet(context, state) {
    return Material(
      child: SingleChildScrollView(
          child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height + 400,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomRight,
                colors: [Colors.black, Colors.red, Colors.black])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(
            child: Text(
              'REPORT DETAILS',
              style: TextStyle(
                  fontFamily: 'PoppinsBold',
                  letterSpacing: 1.5,
                  color: Colors.white,
                  fontSize: 20.0),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            'Date and Time: ${DateFormat("yyyy-MM-dd, hh:mm:ss").format(initialDate)}',
            style: const TextStyle(
                fontFamily: 'PoppinsRegular',
                letterSpacing: 1.5,
                color: Colors.white,
                fontSize: 15.0),
          ),
          const SizedBox(height: 10),
          Text(
            'Location in Maps: ${loggedInUser.latitude}, ${loggedInUser.longitude}',
            style: const TextStyle(
                fontFamily: 'PoppinsRegular',
                letterSpacing: 1.5,
                color: Colors.white,
                fontSize: 15.0),
          ),
          const SizedBox(height: 10),
          Text(
            'Adress: ${loggedInUser.address}',
            style: const TextStyle(
                fontFamily: 'PoppinsRegular',
                letterSpacing: 1.5,
                color: Colors.white,
                fontSize: 15.0),
          ),
          const SizedBox(height: 20),
          isImageLoading
              ? Center(
                  child: Container(
                      height: 400,
                      width: 400,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          image: DecorationImage(
                              image: FileImage(File(pickedImage!.path)),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high))),
                )
              : Container(),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              emergencyValue!,
              style: const TextStyle(
                  fontFamily: 'PoppinsBold',
                  letterSpacing: 1.5,
                  color: Colors.white,
                  fontSize: 15.0),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              _additionalInfoEditingController.text,
              style: const TextStyle(
                  fontFamily: 'PoppinsRegular',
                  letterSpacing: 1.5,
                  color: Colors.white,
                  fontSize: 15.0),
            ),
          ),
          const SizedBox(height: 30),
          (isConfirm == false)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            fixedSize: const Size(150, 50.0),
                            primary: Colors.grey[400]),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              fontSize: 20.0,
                              fontFamily: 'PoppinsBold'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Center(
                      child: ElevatedButton(
                          onPressed: () {
                            uploadImagetoFirebaseStorageAndUploadTheReportDetailsOfUserInDatabase();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            fixedSize: const Size(150, 50.0),
                            primary: const Color(0xffcc021d),
                          ),
                          child: isConfirm == true
                              ? const Center(child: CircularProgressIndicator())
                              : const Text(
                                  'Confirm',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                      fontSize: 20.0,
                                      fontFamily: 'PoppinsBold'),
                                )),
                    )
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ]),
      )),
    );
  }
}

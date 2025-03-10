import 'dart:async';

import 'package:bcons_app/model/user_model.dart';
import 'package:bcons_app/screens/HomeScreen/home_screen.dart';
import 'package:bcons_app/screens/Sign_up_screen/privacyPolicy.dart';
import 'package:bcons_app/screens/Sign_up_screen/termsAndConditions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';

class PhoneAuthSignUp extends StatefulWidget {
  const PhoneAuthSignUp({Key? key}) : super(key: key);

  @override
  State<PhoneAuthSignUp> createState() => _PhoneAuthSignUpState();
}

class _PhoneAuthSignUpState extends State<PhoneAuthSignUp> {
  final _formkey = GlobalKey<FormState>();
  int currentStepIndex = 0;
  final _firstNameEditingController = TextEditingController();
  final _lastNameEditingController = TextEditingController();
  final _midNameEditingController = TextEditingController();
  final _contactNumberEditingController = TextEditingController();
  final _streetEditingController = TextEditingController();
  final _brgyEditingController = TextEditingController();

  DateTime initialDate = DateTime.now();
  DateTime? date;
  String textSelect = 'Select your birthday';
  int? days;

  //Show Date Picker
  Future<void> selectDate(BuildContext context) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: date ?? initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2025),
    );
    if (newDate == null) return;
    if ((newDate != null) && newDate != initialDate) {
      setState(() {
        date = newDate;
        days = findDays(date!.month, date!.year);
      });
    }
  }

  String getDate() {
    if (date == null) {
      return textSelect;
    } else {
      return DateFormat('MM/dd/yyyy').format(date!);
    }
  }

  int? findDays(int month, int year) {
    int day2 = 0;
    if (month == 1 ||
        month == 3 ||
        month == 5 ||
        month == 7 ||
        month == 8 ||
        month == 10 ||
        month == 12) {
      return day2 = 31;
    } else if (month == 4 || month == 6 || month == 9 || month == 11) {
      return day2 = 30;
    } else {
      if (year % 4 == 0) {
        return day2 = 29;
      } else {
        return day2 = 28;
      }
    }
  }

  String? getAge() {
    DateFormat dateFormat = DateFormat('MM/dd/yyyy');
    if (date == null) {
      return null;
    } else {
      int ageYear;
      int ageMonth;
      int? ageDays;
      int yearNow = initialDate.year;
      int monthNow = initialDate.month;
      int dayNow = initialDate.day;
      int birthYear = date!.year;
      int birthMonth = date!.month;
      int birthDay = date!.day;

      if (dayNow - birthDay >= 0) {
        ageDays = (dayNow - birthDay);
      } else {
        ageDays = ((dayNow + days!) - birthDay);
        monthNow = monthNow - 1;
      }
      if (monthNow - birthMonth >= 0) {
        ageMonth = (monthNow - birthMonth);
      } else {
        ageMonth = ((monthNow + 12) - birthMonth);
        yearNow = yearNow - 1;
      }
      yearNow = (yearNow - birthYear);
      ageYear = yearNow;
      return '$ageYear';
    }
  }

  String? bloodTypeValue;
  String? genderValue;
  String? municipalityValue;
  String? provinceValue;

  final municipalityList = [
    'Angat',
    'Balagtas',
    'Baliuag',
    'Bocaue',
    'Bulakan',
    'Bustos',
    'Calumpit',
    'Dona Remdios Trinidad',
    'Guiguinto',
    'Hagonoy',
    'Malolos',
    'Marilao',
    'Norzagaray',
    'Obando',
    'Pandi',
    'Paombong',
    'Plaridel',
    'Pulilan',
    'San Ildefonso',
    'San Miguel',
    'San Rafael',
    'Santa Maria'
  ];
  final provinceList = ['Bulacan'];

  final bloodTypeList = [
    'A+',
    'O+',
    'B+',
    'AB+',
    'A-',
    '0-',
    'B-',
    'AB-',
    'None'
  ];
  final genderList = [
    'Male',
    'Female',
  ];
  DropdownMenuItem<String> buildMenuItem(String emergency) {
    return DropdownMenuItem(
      value: emergency,
      child: Text(
        emergency,
        style: const TextStyle(
            fontFamily: 'PoppinsRegular',
            letterSpacing: 1.5,
            color: Colors.black,
            fontSize: 12.0),
      ),
    );
  }

  String buttonName = 'Send';
  String verificationIDFinal = '';
  String smsCode = '';
  int startTime = 60;
  bool sent = false;
  void startTimer() {
    const onSec = Duration(seconds: 1);
    Timer timer = Timer.periodic(onSec, (timer) {
      if (startTime == 0) {
        setState(() {
          timer.cancel();
          sent = false;
        });
      } else {
        setState(() {
          startTime--;
        });
      }
    });
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber, BuildContext context, Function setData) async {
    PhoneVerificationCompleted verificationCompleted;
    PhoneVerificationFailed verificationFailed;
    PhoneCodeSent codeSent;
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout;

    verificationCompleted = (PhoneAuthCredential phoneAuthCredential) async {
      showSnackBar(context, 'Verification Completed');
    };

    verificationFailed = (FirebaseAuthException exception) {
      showSnackBar(context, exception.toString());
    };

    codeSent = (String verificationID, [int? forceResendingToken]) {
      showSnackBar(
          context, 'Verification Code sent successfully on the phone number');
      setData(verificationID);
    };

    codeAutoRetrievalTimeout = (String verificationID) {
      showSnackBar(context, 'Verification Time Out');
    };
    try {
      firebaseAuth.verifyPhoneNumber(
          timeout: const Duration(seconds: 120),
          phoneNumber: phoneNumber,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void setData(verificationID) {
    setState(() {
      verificationIDFinal = verificationID;
    });
    startTimer();
  }

  void showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool isChecked = false;
  void displayMessage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          AlertDialog dialog = AlertDialog(
            content: const Text(
              'You have accepted the Terms and Conditions',
              style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  letterSpacing: 1.5,
                  fontSize: 15.0,
                  color: Colors.black),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Okay',
                      style: TextStyle(
                          fontFamily: 'PoppinsRegular',
                          letterSpacing: 1.5,
                          fontSize: 15.0,
                          color: Colors.black)))
            ],
          );
          return dialog;
        });
  }

  Future<void> signUpWithPhoneNumber(
      String verificationID, String smsCode, BuildContext context) async {
    AuthCredential authCredential;
    if (_formkey.currentState!.validate()) {
      try {
        authCredential = PhoneAuthProvider.credential(
            verificationId: verificationID, smsCode: smsCode);
        await firebaseAuth
            .signInWithCredential(authCredential)
            .then((value) => {postDetailsToFireStore()})
            .catchError((e) {
          setState(() {});
          Fluttertoast.showToast(msg: e);
        });
      } catch (e) {
        showSnackBar(context, e.toString());
      }
    }
  }

  Future<void> postDetailsToFireStore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    firebase_auth.User? user = firebaseAuth.currentUser;
    UserModel userModel = UserModel();

    userModel.uid = user!.uid;
    userModel.email = 'None';
    userModel.firstName = _firstNameEditingController.text;
    userModel.lastName = _lastNameEditingController.text;
    userModel.middleInitial = _midNameEditingController.text;
    userModel.fullName =
        '${_firstNameEditingController.text} ${_lastNameEditingController.text}';
    userModel.gender = genderValue;
    userModel.contactNumber = _contactNumberEditingController.text;
    userModel.birthday = getDate();
    userModel.age = getAge();
    userModel.bloodType = bloodTypeValue;
    userModel.street = _streetEditingController.text;
    userModel.brgy = _brgyEditingController.text;
    userModel.municipality = municipalityValue;
    userModel.province = provinceValue;
    userModel.visibility = 'No';
    userModel.status = 'online';

    await firebaseFirestore
        .collection('Users')
        .doc(user.uid)
        .set(userModel.toMap())
        .then((value) {
      Fluttertoast.showToast(msg: 'Account Created Successfully');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    });
  }

  final storage = const FlutterSecureStorage();
  void storeTokenAndData(UserCredential userCredential) async {
    await storage.write(
        key: 'token', value: userCredential.credential?.token.toString());
    await storage.write(
        key: 'userCredential', value: userCredential.toString());
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Sign Up',
            style: TextStyle(
                fontFamily: 'PoppinsBold',
                letterSpacing: 2.0,
                color: Colors.white,
                fontSize: 20.0),
          ),
          leading: InkWell(
            child: const Icon(
              Icons.arrow_back,
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: const Color(0xffcc021d),
        ),
        body: SingleChildScrollView(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 60,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomRight,
                      colors: [Colors.black, Colors.red, Colors.black])),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 35, horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                        key: _formkey,
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Column(children: [
                            SizedBox(
                              height: 510.0,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                          primary: Color(0xffcc021d))),
                                  child: Stepper(
                                    currentStep: currentStepIndex,
                                    elevation: 0,
                                    type: StepperType.horizontal,
                                    onStepContinue: () async {
                                      if (currentStepIndex != 2) {
                                        setState(() {
                                          currentStepIndex += 1;
                                        });
                                      } else if (currentStepIndex == 2) {
                                        final SharedPreferences
                                            sharedPreferences =
                                            await SharedPreferences
                                                .getInstance();
                                        sharedPreferences.setString(
                                            'contact',
                                            _contactNumberEditingController
                                                .text);
                                        signUpWithPhoneNumber(
                                            verificationIDFinal,
                                            smsCode,
                                            context);
                                        setState(() {});
                                      }
                                    },
                                    onStepCancel: () {
                                      if (currentStepIndex != 0) {
                                        setState(() {
                                          currentStepIndex -= 1;
                                        });
                                      }
                                    },
                                    steps: [
                                      Step(
                                        state: currentStepIndex <= 0
                                            ? StepState.editing
                                            : StepState.complete,
                                        isActive: currentStepIndex >= 0,
                                        title: const Text('Account'),
                                        content: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              textForm(
                                                  'Last Name',
                                                  _lastNameEditingController,
                                                  'lastNameValidator',
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  45),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              textForm(
                                                  'First Name',
                                                  _firstNameEditingController,
                                                  'firstNameValidator',
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  45.0),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: textForm(
                                                        'Middle Initial',
                                                        _midNameEditingController,
                                                        'null',
                                                        136.0,
                                                        45.0),
                                                  ),
                                                  const SizedBox(width: 10.0),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      height: 45,
                                                      width: 136,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 12,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 0.5)),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton<
                                                                String>(
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              size: 20,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            hint: const Text(
                                                              'Sex',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'PoppinsRegular',
                                                                  letterSpacing:
                                                                      1.5,
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      12.0),
                                                            ),
                                                            value: genderValue,
                                                            isExpanded: true,
                                                            items: genderList
                                                                .map(
                                                                    buildMenuItem)
                                                                .toList(),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                genderValue =
                                                                    value;
                                                              });
                                                            }),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Container(
                                                height: 45,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    border: Border.all(
                                                        color: Colors.black,
                                                        width: 0.5)),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                      icon: const Icon(
                                                        Icons.arrow_drop_down,
                                                        size: 20,
                                                        color: Colors.black,
                                                      ),
                                                      hint: const Text(
                                                        'Blood Type',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'PoppinsRegular',
                                                            letterSpacing: 1.5,
                                                            color:
                                                                Color.fromRGBO(
                                                                    0, 0, 0, 1),
                                                            fontSize: 12.0),
                                                      ),
                                                      value: bloodTypeValue,
                                                      isExpanded: true,
                                                      items: bloodTypeList
                                                          .map(buildMenuItem)
                                                          .toList(),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          bloodTypeValue =
                                                              value;
                                                        });
                                                      }),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      selectDate(context);
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                      side: const BorderSide(
                                                          width: 1.0,
                                                          color: Colors.grey),
                                                    ),
                                                    fixedSize: Size(
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                        45.0),
                                                    primary: Colors.white,
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        getDate(),
                                                        style: const TextStyle(
                                                          fontSize: 14.0,
                                                          fontFamily:
                                                              'PoppinsRegular',
                                                          letterSpacing: 1.5,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ]),
                                      ),
                                      Step(
                                          state: currentStepIndex <= 1
                                              ? StepState.editing
                                              : StepState.complete,
                                          isActive: currentStepIndex >= 1,
                                          title: const Text('Location'),
                                          content: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                textForm(
                                                    'Street/Purok',
                                                    _streetEditingController,
                                                    'streetAndBrgyValidator',
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    45.0),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                textForm(
                                                    'Brgy',
                                                    _brgyEditingController,
                                                    'streetAndBrgyValidator',
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    45.0),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Container(
                                                  height: 45,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.5)),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton<
                                                            String>(
                                                        icon: const Icon(
                                                          Icons.arrow_drop_down,
                                                          size: 20,
                                                          color: Colors.black,
                                                        ),
                                                        hint: const Text(
                                                          'Municipality',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'PoppinsRegular',
                                                              letterSpacing:
                                                                  1.5,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12.0),
                                                        ),
                                                        value:
                                                            municipalityValue,
                                                        isExpanded: true,
                                                        items: municipalityList
                                                            .map(buildMenuItem)
                                                            .toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            municipalityValue =
                                                                value;
                                                          });
                                                        }),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Container(
                                                  height: 45,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.5)),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton<
                                                            String>(
                                                        icon: const Icon(
                                                          Icons.arrow_drop_down,
                                                          size: 20,
                                                          color: Colors.black,
                                                        ),
                                                        hint: const Text(
                                                          'Province',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'PoppinsRegular',
                                                              letterSpacing:
                                                                  1.5,
                                                              color: Color
                                                                  .fromRGBO(0,
                                                                      0, 0, 1),
                                                              fontSize: 12.0),
                                                        ),
                                                        value: provinceValue,
                                                        isExpanded: true,
                                                        items: provinceList
                                                            .map(buildMenuItem)
                                                            .toList(),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            provinceValue =
                                                                value;
                                                          });
                                                        }),
                                                  ),
                                                ),
                                              ])),
                                      Step(
                                          state: StepState.complete,
                                          isActive: currentStepIndex >= 2,
                                          title: const Text('Confirm'),
                                          content: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                height: 50,
                                              ),
                                              numberField(
                                                  _contactNumberEditingController),
                                              const SizedBox(height: 10.0),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Row(children: [
                                                  Expanded(
                                                      child: Container(
                                                    height: 1,
                                                    color: Colors.black,
                                                  )),
                                                  const Text(
                                                    ' Enter 6 OTP digit ',
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontFamily:
                                                          'PoppinsRegular',
                                                      letterSpacing: 1.5,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Container(
                                                    height: 1,
                                                    color: Colors.black,
                                                  )),
                                                ]),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              otpField(),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              RichText(
                                                  text: TextSpan(children: [
                                                const TextSpan(
                                                  text: 'Send OTP again in ',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontFamily:
                                                        'PoppinsRegular',
                                                    color: Colors.black,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '00:$startTime',
                                                  style: const TextStyle(
                                                      fontSize: 12.0,
                                                      fontFamily:
                                                          'PoppinsRegular',
                                                      letterSpacing: 1.5,
                                                      color: Color(0xffcc021d)),
                                                ),
                                                const TextSpan(
                                                  text: ' sec',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontFamily:
                                                        'PoppinsRegular',
                                                    letterSpacing: 1.5,
                                                    color: Colors.black,
                                                  ),
                                                )
                                              ])),
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    splashRadius: 5.0,
                                                    value: isChecked,
                                                    onChanged: (b) {
                                                      setState(() {
                                                        isChecked = b!;

                                                        isChecked
                                                            ? displayMessage()
                                                            : null;
                                                      });
                                                    },
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const TermsAndConditions()));
                                                      });
                                                    },
                                                    child: Text(
                                                      'Terms and Conditions',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[600],
                                                          fontSize: 10.0,
                                                          fontFamily:
                                                              'PoppinsRegular'),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Text(
                                                    '|',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                  const SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const PrivacyPolicy()));
                                                      });
                                                    },
                                                    child: Text(
                                                      'Privacy Policy',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[600],
                                                          fontSize: 10.0,
                                                          fontFamily:
                                                              'PoppinsRegular'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ]),
                        ))
                  ],
                ),
              )),
        ));
  }

  Widget textForm(String labelText, TextEditingController controller,
      String validator, double width, double height) {
    const String firstNameValidator = 'firstNameValidator';
    const String lastNameValidator = 'lastNameValidator';

    const String streetValidator = 'streetAndBrgyValidator';
    const String brgyValidator = 'streetAndBrgyValidator';

    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        autofocus: false,
        controller: controller,
        onSaved: (value) {
          controller.text = value!;
        },
        validator: (value) {
          if (firstNameValidator == validator) {
            RegExp regex = RegExp(r'^.{2,}$');
            if (value!.isEmpty) {
              return ("First name is required");
            }
            if (!regex.hasMatch(value)) {
              return ("Enter valid first name(Min. 2 Characters)");
            }
            return null;
          }
          if (lastNameValidator == validator) {
            RegExp regex = RegExp(r'^.{2,}$');
            if (value!.isEmpty) {
              return ("Last name is required");
            }
            if (!regex.hasMatch(value)) {
              return ("Enter valid last name(Min. 2 Characters)");
            }
            return null;
          }

          if (streetValidator == validator) {
            if (value!.isEmpty) {
              return ("Street/Purok are required");
            }
            return null;
          }
          if (brgyValidator == validator) {
            if (value!.isEmpty) {
              return ("Brgy are required");
            }
            return null;
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          labelText: labelText,
          fillColor: Colors.white,
          filled: true,
          labelStyle: const TextStyle(
            fontSize: 12.0,
            color: Colors.black,
            fontFamily: 'PoppinsRegular',
            letterSpacing: 1.5,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(width: 1.5, color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(width: 1, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget numberField(TextEditingController controller) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 65,
        child: TextFormField(
          autofocus: false,
          keyboardType: TextInputType.number,
          controller: controller,
          maxLength: 10,
          onSaved: (value) {
            controller.text = value!;
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
            hintText: '9xxxxxxxxx',
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 3),
              child: Text(
                ' (+63) ',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                  fontFamily: 'PoppinsRegular',
                  letterSpacing: 1.5,
                ),
              ),
            ),
            suffixIcon: InkWell(
              onTap: sent
                  ? null
                  : () async {
                      setState(() {
                        startTime = 60;
                        sent = true;
                        buttonName = 'Resend';
                      });
                      startTimer();
                      await verifyPhoneNumber(
                          '+63 ${_contactNumberEditingController.text}',
                          context,
                          setData);
                    },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
                child: Text(
                  buttonName,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: sent ? Colors.grey : Colors.black,
                    fontFamily: 'PoppinsRegular',
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            fillColor: Colors.white,
            filled: true,
            hintStyle: TextStyle(
              fontSize: 15.0,
              color: Colors.grey[600],
              fontFamily: 'PoppinsRegular',
              letterSpacing: 1.5,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(width: 1.5, color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(width: 1.0, color: Colors.black),
            ),
          ),
        ));
  }

  Widget otpField() {
    return OTPTextField(
      length: 6,
      width: MediaQuery.of(context).size.width,
      fieldWidth: 40,
      otpFieldStyle: OtpFieldStyle(
          borderColor: Colors.black, backgroundColor: Colors.transparent),
      style: const TextStyle(
        fontSize: 15.0,
        color: Colors.black,
        fontFamily: 'PoppinsRegular',
      ),
      textFieldAlignment: MainAxisAlignment.spaceAround,
      fieldStyle: FieldStyle.underline,
      onCompleted: (pin) {
        print("Completed: " + pin);
        setState(() {
          smsCode = pin;
        });
      },
    );
  }
}

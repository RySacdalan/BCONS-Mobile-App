import 'package:flutter/material.dart';

class ManualReportScreen extends StatefulWidget {
  const ManualReportScreen({Key? key}) : super(key: key);

  @override
  _ManualReportScreenState createState() => _ManualReportScreenState();
}

class _ManualReportScreenState extends State<ManualReportScreen> {
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
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 90.0, 30.0, 30.0),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'CHOOSE MANUAL REPORT',
                  style: TextStyle(
                      color: Color(0xffd90824),
                      letterSpacing: 2.0,
                      fontFamily: 'PoppinsRegular',
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30.0),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: 165,
                        height: 100.0,
                        decoration: BoxDecoration(
                            color: const Color(0xffd90824),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              'EARTHQUAKE',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                fontFamily: 'PoppinsBold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: 165,
                        height: 100.0,
                        decoration: BoxDecoration(
                            color: const Color(0xffd90824),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              'ACCIDENT',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                fontFamily: 'PoppinsBold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: 165,
                        height: 100.0,
                        decoration: BoxDecoration(
                            color: const Color(0xffd90824),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              'FIRE',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                fontFamily: 'PoppinsBold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: 165,
                        height: 100.0,
                        decoration: BoxDecoration(
                            color: const Color(0xffd90824),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              'HEALTH',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                fontFamily: 'PoppinsBold',
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              'EMERGENCY',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                fontFamily: 'PoppinsBold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: 165,
                        height: 100.0,
                        decoration: BoxDecoration(
                            color: const Color(0xffd90824),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              'FLOOD',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                fontFamily: 'PoppinsBold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: 165,
                        height: 100.0,
                        decoration: BoxDecoration(
                            color: const Color(0xffd90824),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text(
                              'CRIME',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                fontFamily: 'PoppinsBold',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  bool _rememberMe = false;
  late SharedPreferences prefs;
  String qrcode = '';
  String acText = '';
  String stampI = '---';
  String stampO = '---';
  String stampLabel = '';
  String? nameText = '';
  String? emailText = '';
  String BSText = '';
  String SText = '';
  String SRText = '';
  String BSN = '';
  String SN = '';
  String SRN = '';
  DateFormat dateN = DateFormat("yyyy-MM-dd");
  DateFormat dateTimeN = DateFormat("yyyy-MM-dd HH:mm:ss");

  @override
  void initState() {
    super.initState();
    _getPrefs();
  }

  TimerBuilder tb = TimerBuilder.periodic(
    Duration(seconds: 1),
    builder: (context) {
      DateFormat date = DateFormat("dd-MM-yyyy");
      DateFormat time = DateFormat("HH:mm:ss");
      "${date.format(DateTime.now())} ${time.format(DateTime.now())}";
      return Text(
        "${date.format(DateTime.now())} ${time.format(DateTime.now())}",
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'OpenSans',
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      );
    },
  );

  Future<void> _emptyPrefs(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove('name');
    prefs.remove('email');
    prefs.remove('speciality');
    prefs.remove('speciality_role');
    prefs.remove('building_site');
    prefs.remove('speciality_id');
    prefs.remove('speciality_role_id');
    prefs.remove('building_site_id');
    prefs.remove('stampI');
    prefs.remove('stampO');
    Navigator.pushReplacementNamed(context, "/login");
  }

  Future<void> _nextActivity() async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove('stampI');
    prefs.remove('stampO');
    prefs.remove('acCode');
    setState(() {
      acText = "";
      stampI = "---";
      stampO = "---";
      stampLabel = "Marcar entrada";
    });
  }

  Future<void> _checkIn() async {
    prefs = await SharedPreferences.getInstance();
    String data = dateTimeN.format(DateTime.now());
    prefs.setString('stampI', data);
    setState(() {
      stampI = data;
      if (stampI == '---') {
        stampLabel = "Marcar entrada";
      } else if (stampO == '---') {
        stampLabel = "Marcar salida";
      } else {
        stampLabel = "Enviar asistencia";
      }
    });
  }

  Future<void> _checkOut() async {
    prefs = await SharedPreferences.getInstance();
    String data = dateTimeN.format(DateTime.now());
    prefs.setString('stampO', data);
    setState(() {
      stampO = data;
      if (stampI == '---') {
        stampLabel = "Marcar entrada";
      } else if (stampO == '---') {
        stampLabel = "Marcar salida";
      } else {
        stampLabel = "Enviar asistencia";
      }
    });
  }

  Future<void> _getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if (stampI == '---') {
      stampLabel = "Marcar entrada";
    } else if (stampO == '---') {
      stampLabel = "Marcar salida";
    } else {
      stampLabel = "Enviar asistencia";
    }
    nameText = prefs.getString('name');
    emailText = prefs.getString('email');
    BSText = prefs.getString('building_site')!;
    SText = prefs.getString('speciality')!;
    SRText = prefs.getString('speciality_role')!;
    BSN = prefs.getString('building_site_id')!;
    SN = prefs.getString('speciality_id')!;
    SRN = prefs.getString('speciality_role_id')!;
    stampI = prefs.getString('stampI') ?? '---';
    stampO = prefs.getString('stampO') ?? '---';
    acText = prefs.getString('acCode') ?? '';
    setState(() {
      if (stampI == '---') {
        stampLabel = "Marcar entrada";
      } else if (stampO == '---') {
        stampLabel = "Marcar salida";
      } else {
        stampLabel = "Enviar asistencia";
      }
      nameText = prefs.getString('name');
      emailText = prefs.getString('email');
      BSText = prefs.getString('building_site')!;
      SText = prefs.getString('speciality')!;
      SRText = prefs.getString('speciality_role')!;
      BSN = prefs.getString('building_site_id')!;
      SN = prefs.getString('speciality_id')!;
      SRN = prefs.getString('speciality_role_id')!;
      stampI = prefs.getString('stampI') ?? '---';
      stampO = prefs.getString('stampO') ?? '---';
      acText = prefs.getString('acCode') ?? '';
    });
  }

  Future<void> _marcarLabel() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      stampI = prefs.getString('stampI') ?? '---';
      stampO = prefs.getString('stampO') ?? '---';
      if (stampI == '---') {
        stampLabel = "Marcar entrada";
      } else if (stampO == '---') {
        stampLabel = "Marcar salida";
      } else {
        stampLabel = "Enviar asistencia";
      }
    });
  }

  Future<int> activityRequest(String sStampI, String sStampO, String sSR_ID,
      String sBS_ID, String sCode) async {
    final http.Response response = await http.post(
      Uri.tryParse('https://app.lekapp.cl/api/uploadData')!,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': emailText as String,
        'stampI': sStampI,
        'stampO': sStampO,
        'SR_ID': sSR_ID,
        'BS_ID': sBS_ID,
        'code': sCode,
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      _nextActivity();
      return 1;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Code: ' + response.statusCode.toString());
    }
  }

  Future<void> _marcar() async {
    if (stampI != '---' && stampO != '---') {
      activityRequest(stampI, stampO, SRN, BSN, acText);
      _marcarLabel();
    } else {
      prefs = await SharedPreferences.getInstance();

      //qrcode = await scanner.scan() ?? '';

      String qrcode = "";

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MobileScanner(
              allowDuplicates: false,
              onDetect: (barcode, args) {
                qrcode = barcode.rawValue ?? '';

                String decoded = utf8.decode(base64.decode(qrcode));

                List<String> splitLvl1 =
                    decoded.split("|"); // DATE | BID | ACT_CODE | SR
                if (splitLvl1.length == 4) {
                  if (stampI == "---") {
                    //Marcar entrada
                    if (splitLvl1[0] == dateN.format(DateTime.now())) {
                      if (splitLvl1[1] == BSN) {
                        prefs.setString("acCode", splitLvl1[2]);
                        acText = splitLvl1[2];
                        _checkIn();
                      } else {
                        Fluttertoast.showToast(
                            msg: "Obra equivocada: ${BSN} vs ${splitLvl1[1]}",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    } else {
                      //Ya no es el día que corresponde

                      Fluttertoast.showToast(
                          msg: "Fecha equivocada",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);

                      _nextActivity();
                    }
                  } else if (stampO == "---") {
                    //Marcar salida

                    if (splitLvl1[0] == dateN.format(DateTime.now())) {
                      if (splitLvl1[1] == BSN) {
                        if (splitLvl1[2] == prefs.getString("acCode")) {
                          _checkOut();
                        } else {
                          Fluttertoast.showToast(
                              msg: "Actividad equivocada",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg: "Obra equivocada",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    } else {
                      //Ya no es el día que corresponde

                      Fluttertoast.showToast(
                          msg: "Fecha equivocada",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);

                      _nextActivity();
                    }
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "El código escaneado no es una actividad",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
                Navigator.of(context).pop();
              }),
        ),
      );
    }
  }

  Widget _buildLogoutBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      alignment: Alignment.topLeft,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => _emptyPrefs(context),
        padding: EdgeInsets.all(20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Salir',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _infoContainer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 30.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(nameText as String,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenSans',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left),
            subtitle: Text(
              emailText as String,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          ListTile(
            title: Text("${SText} (${SRText})",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenSans',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left),
            subtitle: Text("en ${BSText}",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenSans',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right),
          ),
          ListTile(
            title: Text(
              "Actividad",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            subtitle: Text(
              acText,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          ListTile(
            title: Text(
              "Hora entrada: ${stampI}",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          ListTile(
            title: Text(
              "Hora salida: ${stampO}",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      alignment: Alignment.bottomRight,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => _marcar(),
        padding: EdgeInsets.all(20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          stampLabel,
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF5AE73),
                      Color(0xFFF1A461),
                      Color(0xFFE08D47),
                      Color(0xFFE58A39),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 60.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildLogoutBtn(context),
                      tb,
                      _infoContainer(),
                      _checkBtn(context),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

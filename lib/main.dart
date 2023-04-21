import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final title = 'BLE Set Notification';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

    final FlutterBluePlus blue = FlutterBluePlus.instance;

  @override
  void initState() {
    blue.scanResults.listen((results) {
      print("검색 중 ...");
      print("results : $results");
      if(results.isNotEmpty){
        setState(() {
          result = results;
        });
      }
    });
    blue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        print("device : $device");
      }
    });
    super.initState();
  }

  List? result;
  bool check = false;
  String viewTxt = "대기중...";

  Future blueBtn() async{
    setState(() {
      check = true;
      viewTxt = "검색중...";
    });
    var bl =  await blue.startScan(
      scanMode: ScanMode.balanced,
        allowDuplicates:true,timeout: Duration(seconds: 12))
      .timeout(Duration(seconds: 12), onTimeout: () async{
        await blue.stopScan();
        setState(() {
          check = false;
          viewTxt = "ERR";
        });
      });
    print("startScan : $bl");

    await Future.delayed(Duration(seconds: 13), () async {
      await blue.stopScan();
      setState(() {
        check = false;
        if(this.result == null) viewTxt = "대기중...";
      });
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            
            ElevatedButton(
                child: Text("Blue"),
                onPressed: this.blueBtn,
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                color: check ? Colors.blue : Colors.red,
                child: Text(result?.toString()?? this.viewTxt)
              ),
          ],)

    )
    );

  }
}